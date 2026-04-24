import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_life/screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_routes.dart';
import '../constant/constant.dart';
import '../services/user_assignment_service.dart';
import '../utils/SubscriptionExpiredDialog.dart';



class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- STATUS & BLOCKING FLAGS ---
  final userStatus = 'checking'.obs; // Starts as 'checking'
  final isSubscriptionDialogOpen = false.obs;


  // --- COMMON VARIABLES ---
  var userName = "".obs;
  var userRole = "".obs; // 'user', 'admin', 'trainer'

  // --- USER DATA ---
  var workoutsCompleted = 0.obs;
  var caloriesBurned = 0.obs;
  var weeklyProgress = 0.0.obs;

  // --- ADMIN DATA ---
  var totalUsers = 0.obs;
  var totalTrainers = 0.obs;
  var pendingTrainers = <QueryDocumentSnapshot>[].obs;
  var pendingUsers = <QueryDocumentSnapshot>[].obs;

  // --- TRAINER DATA ---
  var isTrainerApproved = false.obs;
  var activeStudents = 0.obs;
  var classesGiven = 0.obs;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;
  var isAccountApproved = false.obs;

  // --- LIVE CLASS DATA (NEW) ---
  var liveClasses = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    super.onInit();
    // Set name immediately so "Hello, Name" shows on first frame (from prefs or email)
    final u = _auth.currentUser;
    if (AppConstants.userName.trim().isNotEmpty) {
      userName.value = AppConstants.userName.trim();
    } else if (u?.email != null) {
      userName.value = u!.email!.split('@').first;
    } else {
      userName.value = 'User';
    }
    if (AppConstants.role.isNotEmpty) {
      userRole.value = AppConstants.role;
    }
    _startUserStatusListener();
  }

  void _initialSetup() {
    // 1. Load Basic Info — ensure name/role are set (from Auth if still empty)
    if (userName.value.isEmpty) {
      final u = _auth.currentUser;
      userName.value = (u?.displayName?.trim().isNotEmpty == true)
          ? u!.displayName!.trim()
          : (u?.email != null ? u!.email!.split('@').first : 'User');
    }
    if (userRole.value.isEmpty) {
      userRole.value = AppConstants.role;
    }

    // 2. Load Specific Data based on Role
    // 1. Initial Load (Fast)
    isTrainerApproved.value = AppConstants.isApproved.value;

    // 2. START REAL-TIME LISTENER (The Fix)
    // This watches YOUR profile for changes (like isApproved toggling)
    _listenToMyProfile();

    // 3. Load Data based on initial role
    _refreshDashboardData();

  }

// ==================================================
  // 1. STATUS LISTENER (The Gatekeeper)
  // ==================================================
  void _startUserStatusListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    print("🔒 Starting Status Check...");

    void setUserNameAndRole(Map<String, dynamic>? data) {
      // Use latest auth user when snapshot arrives
      final u = _auth.currentUser;
      final role = data != null ? (data['role']?.toString() ?? 'user') : AppConstants.role;
      userRole.value = role;

      String name = '';
      if (data != null) {
        // Prefer Firestore name fields (profile saves as 'name'; also support displayName/fullName)
        name = (data['name']?.toString().trim()) ?? '';
        if (name.isEmpty) name = (data['displayName']?.toString().trim()) ?? '';
        if (name.isEmpty) name = (data['fullName']?.toString().trim()) ?? '';
      }
      if (name.isEmpty && u != null) {
        if (u.displayName != null && u.displayName!.trim().isNotEmpty) {
          name = u.displayName!.trim();
        } else if (u.email != null) {
          name = u.email!.split('@').first;
        }
      }
      userName.value = name.isEmpty ? 'User' : name;
      if (name.isNotEmpty) {
        AppConstants.userName = name;
        AppConstants.setUserName(name); // persist for next app launch
      }
    }

    // One-time fetch from SERVER so we get latest name (e.g. "Dattani PD" from profile)
    _db.collection('users').doc(user.uid).get(const GetOptions(source: Source.server)).then((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawStatus = data['status'];
        final bool isActive = rawStatus == true ||
            rawStatus == 'true' ||
            rawStatus == 'active' ||
            rawStatus == 'pending' ||
            rawStatus == null;
        if (isActive) {
          setUserNameAndRole(data);
        }
      }
    });

    _db.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Status can be: true/false (bool) or 'active'/'pending'/'deactive' (string)
        final rawStatus = data['status'];
        final bool isActive = rawStatus == true ||
            rawStatus == 'true' ||
            rawStatus == 'active' ||
            rawStatus == 'pending' || // pending users can open app but see approval message
            rawStatus == null; // treat missing as active
        final bool isDeactive = rawStatus == false ||
            rawStatus == 'false' ||
            rawStatus == 'deactive';

        userStatus.value = isActive ? 'active' : (isDeactive ? 'deactive' : rawStatus?.toString() ?? 'active');
        print("👤 User Status: $rawStatus → active=$isActive deactive=$isDeactive");

        if (isActive) {
          // ✅ ACTIVE: set approval, name, close dialog if open, load app
          final role = data['role']?.toString() ?? 'user';
          bool approved = role == 'admin' ||
              (data['isApproved'] == true || data['isApproved'] == "true");
          isAccountApproved.value = approved;
          AppConstants.setApproved(approved);

          setUserNameAndRole(data);

          if (isSubscriptionDialogOpen.value) {
            _closeSubscriptionDialog();
          }
          _initialSetup();
          _listenToLiveClasses();
        } else if (isDeactive) {
          // ❌ DEACTIVE (status false or 'deactive'): show subscription expired dialog
          if (!isSubscriptionDialogOpen.value) {
            showSubscriptionExpiredDialog();
          }
        }
      } else {
        // No Firestore doc yet (e.g. just signed up) — still show name from Auth for role == user
        userStatus.value = 'active';
        setUserNameAndRole(null);
        _initialSetup();
        _listenToLiveClasses();
      }
    });
  }

  void showSubscriptionExpiredDialog() {
    isSubscriptionDialogOpen.value = true;
    Get.dialog(
      SubscriptionExpiredDialog(),
      barrierDismissible: false, // 🔒 Block interaction
    ).then((_) => isSubscriptionDialogOpen.value = false);
  }

  void _closeSubscriptionDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Close dialog
    }
    isSubscriptionDialogOpen.value = false;
  }

  List<Map<String, dynamic>> get upcomingClasses {
    DateTime now = DateTime.now();

    // બફર ટાઈમ: જો ક્લાસ ૧ કલાક પહેલા ચાલુ થયો હોય તો પણ 'Live' ગણીને બતાવો
    DateTime liveBuffer = now.subtract(const Duration(hours: 1));

    var filteredList = liveClasses.where((meeting) {
      Timestamp? ts = meeting['startTime'];
      if (ts == null) return false;

      DateTime meetingTime = ts.toDate();

      // શરત: ક્લાસનો ટાઈમ 'liveBuffer' પછીનો હોવો જોઈએ
      return meetingTime.isAfter(liveBuffer);
    }).toList();

    // Sorting: જે તારીખ નજીક હોય તે પહેલા દેખાય (Ascending)
    filteredList.sort((a, b) {
      Timestamp t1 = a['startTime'];
      Timestamp t2 = b['startTime'];
      return t1.compareTo(t2);
    });

    return filteredList;
  }

  // --- UPDATED LISTENER (Show ALL Meetings - Past & Future) ---
  void _listenToLiveClasses() {
    _db.collection('live_classes')
    // .where('status', isEqualTo: 'upcoming') // આ લાઈન કાઢી નાખવી કેમ કે આપણે તારીખ પરથી ફિલ્ટર કરીએ છીએ
        .orderBy('startTime', descending: false) // ✅ False: નજીકની તારીખ પહેલા આવશે
        .snapshots()
        .listen((snapshot) {

      liveClasses.value = snapshot.docs.map((doc) => doc.data()).toList();

    }, onError: (e) {
      print("Error fetching classes: $e");
    });
  }

  void _listenToMyProfile() {
    String myUid = _auth.currentUser!.uid;

    _profileSubscription = _db.collection('users').doc(myUid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        // Safe way to get data as a Map
        var data = snapshot.data() as Map<String, dynamic>;

        // 1. Check Role
        String role = data['role'] ?? 'user';

        // 2. Determine Approval Status
        bool newStatus;
        if (role == 'admin') {
          // Admins are ALWAYS approved, even if the field is missing
          newStatus = true;
        } else {
          // Users/Trainers must check the field (handle missing field safely)
          newStatus = data['isApproved'] == true || data['isApproved'] == "true";
        }

        // 3. Update State if changed
        if (isAccountApproved.value != newStatus) {
          isAccountApproved.value = newStatus;
          AppConstants.setApproved(newStatus);
          _refreshDashboardData();
        }
      }
    });
  }

  void _refreshDashboardData() {
    // If NOT approved, don't load sensitive data
    if (!isAccountApproved.value) return;

    if (userRole.value == 'admin') {
      _loadAdminData();
      _loadUserData();
    }
    else if (userRole.value == 'trainer') {
      // Only load data if approved
      if (isTrainerApproved.value) {
        _loadTrainerData();
        _loadUserData();
      }
    }
    else {
      _loadUserData();
    }
  }

  // --- DATA LOADERS ---

  void _loadUserData() {
    // Mock Data for User
    workoutsCompleted.value = 12;
    caloriesBurned.value = 850;
    weeklyProgress.value = 0.7;
  }

  void _loadTrainerData() async {
    String trainerId = _auth.currentUser!.uid;

    try {
      // --- 1. ACTIVE STUDENTS: Count users assigned to this trainer (assignedTrainerId) ---
      final assignedUsersSnap = await _db
          .collection('users')
          .where('role', isEqualTo: 'user')
          .where('assignedTrainerId', isEqualTo: trainerId)
          .get();
      activeStudents.value = assignedUsersSnap.docs.length;

      // --- 2. CLASSES GIVEN (unchanged) ---
      final classQuery = await _db
          .collection('live_classes')
          .where('trainerId', isEqualTo: trainerId)
          .get();

      // ✅ Current Time Logic
      DateTime now = DateTime.now();
      // બફર ટાઈમ: જો ક્લાસ ૧ કલાક પહેલા ચાલુ થયો હોય તો પણ ગણો (Live)
      DateTime liveBuffer = now.subtract(const Duration(hours: 1));

      // 🔍 Filter: ફક્ત એવા જ ક્લાસ ગણો જેનો સમય 'liveBuffer' પછીનો હોય
      int activeClassCount = classQuery.docs.where((doc) {
        var data = doc.data();
        if (data['startTime'] == null) return false;

        Timestamp ts = data['startTime'];
        return ts.toDate().isAfter(liveBuffer);
      }).length;

      // ✅ Update Variable
      classesGiven.value = activeClassCount;

    } catch (e) {
      print("Error fetching trainer stats: $e");
      activeStudents.value = 0;
      classesGiven.value = 0;
    }
  }

  void _loadAdminData() {
    _db.collection('users').where('role', isEqualTo: 'user').snapshots().listen((snap) => totalUsers.value = snap.docs.length);
    _db.collection('users').where('role', isEqualTo: 'trainer').snapshots().listen((snap) => totalTrainers.value = snap.docs.length);

    _db.collection('users')
        .where('role', isEqualTo: 'trainer')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .listen((snap) => pendingTrainers.value = snap.docs);

    _db.collection('users')
        .where('role', isEqualTo: 'user')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .listen((snap) => pendingUsers.value = snap.docs);
  }

  // --- ACTIONS ---

// --- UPDATED JOIN ACTION (Fixed) ---
  Future<void> joinLiveClass([String? specificLink]) async {
    String linkToOpen = "";

    if (specificLink != null && specificLink.isNotEmpty) {
      // Case 1: Link passed directly (from User List)
      linkToOpen = specificLink;
    }
    else if (liveClasses.isNotEmpty) {
      // Case 2: No link passed (from Trainer Button), use the latest one
      linkToOpen = liveClasses.first['meetingLink'] ?? "";
    }

    if (linkToOpen.isEmpty) {
      Get.snackbar("Info", "No live class link found.");
      return;
    }

    final Uri url = Uri.parse(linkToOpen);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Get.snackbar("Error", "Could not open meeting link: $e");
    }
  }

  Future<void> approveTrainer(String uid) async {
    await _db.collection('users').doc(uid).update({'isApproved': true});
    Get.snackbar("Success", "Trainer Approved!", backgroundColor: Colors.green, colorText: Colors.white);
  }

  /// Approve a user (role == 'user') and assign a trainer. Trainer must be selected before calling.
  /// Uses UserAssignmentService to update user doc and add user's UID to assignedUsers in plan assignments.
  Future<void> approveUser({
    required String userId,
    required String trainerId,
    required String trainerName,
    String? userEmail,
  }) async {
    await UserAssignmentService.approveUser(
      userId: userId,
      trainerId: trainerId,
      trainerName: trainerName,
      userEmail: userEmail,
    );
    Get.snackbar("Success", "User Approved and Trainer Assigned Successfully", backgroundColor: Colors.green, colorText: Colors.white);
  }

  void logout() async {
    await AppConstants.logout();
  }
}
