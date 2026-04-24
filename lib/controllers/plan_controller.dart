import 'package:get/get.dart';

// class PlanController extends GetxController {
//   var isLoading = false.obs;
//   var plans = <Map<String, dynamic>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadStaticPlans();
//   }
//
//   void loadStaticPlans() {
//     // Adding data manually to match your screenshots
//     plans.value = [
//       {
//         "title": "12 Weeks Transformation",
//         "description": "This is my most comprehensive all-in-one program available, where we work together to help you reach your physique goals.",
//         "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
//         "price": "Free",
//         "duration": "for first week",
//         "features": [
//           "One on one coaching",
//           "Weekly 1-1 video calls",
//           "Personalised fitness plan with video demonstrations"
//         ]
//       },
//       {
//         "title": "21 days Kickstarter",
//         "description": "This 21 days program is designed to kick start your health journey using a simple nutritious diet plan and basic exercises.",
//         "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
//         "price": "\$40",
//         "duration": "for 3 weeks",
//         "features": [
//           "Video demonstrations & instructions",
//           "Regular progress check-ins",
//           "Daily workout and nutrition logging"
//         ]
//       },
//       {
//         "title": "Get \"Shredded\"",
//         "description": "A gym based program to help you lose weight and body fat whilst gaining muscle tone and strength.",
//         "image": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
//         "price": "\$120",
//         "duration": "for 8 weeks",
//         "features": [
//           "Personalised fitness plan",
//           "Personalised meal plan & recipes",
//           "Regular progress check-ins"
//         ]
//       },
//       {
//         "title": "One on One Personal Training",
//         "description": "This is my most comprehensive program available where we work together to help you reach your physique goals.",
//         "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
//         "price": "\$80",
//         "duration": "Monthly",
//         "features": [
//           "One on one online coaching",
//           "Personalised fitness plan with videos",
//           "Personalised meal plan & recipes"
//         ]
//       },
//     ];
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/model.dart';
import 'controller.dart';


///old 2201
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // ✅ Stripe Import
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // ✅ HTTP Import

class PlanController extends GetxController {
  // ✅ PUBLISHABLE KEY
  static const String publishableKey = 'pk_live_51OZ2XxKItFmRol0wCSlDtZdesbJJ6fVNn1UskRwJIEZdUCLxaAvxKYxKpq0ncfH6emu7AhSpatFadlDNIeQBL0NK0071mwA5c9';

  // ✅ BACKEND URL (Your Vercel URL)
  static const String backendUrl = 'https://stripe-backend-sigma.vercel.app/api';

  var isLoading = false.obs;
  var plans = <Map<String, dynamic>>[].obs;
  var purchasedPlanTitles = <String>[].obs;
  var purchasedPlanDates = <String, DateTime>{}.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🗓️ TRACKING PROGRESS
  var completedDates = <DateTime>[].obs; // Stores dates the user finished a workout
  var planStartDate = Rx<DateTime?>(null); // When did they buy the plan?

  @override
  void onInit() {
    super.onInit();
    Stripe.publishableKey = publishableKey; // ✅ Stripe Init
    fetchPlansFromFirebase();
    fetchPurchasedPlans();
  }


  final List<String> defaultGymImages = [
    "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg",
    "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg",
    "https://images.pexels.com/photos/2261145/pexels-photo-2261145.jpeg",
    "https://images.pexels.com/photos/949126/pexels-photo-949126.jpeg"
  ];

  // 1️⃣ Fetch Plans & Include Duration Data
  Future<void> fetchPlansFromFirebase() async {
    try {
      isLoading.value = true;
      var snapshot = await _db.collection('workout_plans').get();

      plans.value = snapshot.docs.map((doc) {
        var data = doc.data();
        String title = data['name'] ?? "Unknown Plan";
// ✅ ઈમેજ લોજિક: જો imageUrl ન હોય અથવા ખાલી સ્ટ્રિંગ હોય
        String? firestoreImg = data['imageUrl']?.toString().trim();

        // Price Logic
        double priceValue = 0.0;
        String priceText = "Free";
        if (data['price'] != null) {
          var rawPrice = data['price'];
          priceValue = (rawPrice is String) ? (double.tryParse(rawPrice) ?? 0.0) : (rawPrice is int ? rawPrice.toDouble() : rawPrice);
          priceText = priceValue == 0.0 ? "Free" : "\$${priceValue.toInt()}";
        }

        // ✅ Duration Logic (Robust Parsing)
        String durationText = "4 Weeks";
        String durationUnit = data['durationUnit'] ?? "Weeks";
        int durationValue = 4; // Default

        if (data['duration'] != null) {
          String valStr = data['duration'].toString();
          durationValue = int.tryParse(valStr) ?? 0;

          if (durationValue == 0) {
            durationText = "Lifetime";
          } else {
            durationText = "$durationValue $durationUnit";
          }
        }

        return {
          'id': doc.id,
          'title': title,
          'description': data['description'] ?? "Step-by-step workout plan.",
          'price': priceText,
          'priceValue': priceValue,
          'durationText': durationText, // Display text (e.g. "4 Weeks")
          'durationValue': durationValue, // ✅ Raw Number (e.g. 4)
          'durationUnit': durationUnit,   // ✅ Raw Unit (e.g. "Weeks")
          'image': (firestoreImg != null && firestoreImg.isNotEmpty)
              ? firestoreImg
              : defaultGymImages[doc.id.hashCode % defaultGymImages.length],

          'features': ["Access to exercises", "Diet guide", "Trainer support", "Progress tracking"],
          'woo_product_id': data['wooProductId'] ?? data['woo_product_id'],
          'wooProductId': data['wooProductId'] ?? data['woo_product_id'],
        };
      }).toList();

    } catch (e) {
      print("Error fetching plans: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2️⃣ Fetch Purchased Plans
  // Fetches from user_purchases/{currentUid}/plans and fills purchasedPlanDates by planId (String).
  Future<void> fetchPurchasedPlans() async {
    try {
      final String? currentUid = _auth.currentUser?.uid;
      if (currentUid == null || currentUid.isEmpty) {
        purchasedPlanDates.value = {};
        return;
      }

      final snapshot = await _db
          .collection('user_purchases')
          .doc(currentUid)
          .collection('plans')
          .get();

      final Map<String, DateTime> tempMap = {};

      for (final docSnap in snapshot.docs) {
        final data = docSnap.data();
        final String? pId = data['planId']?.toString().trim();
        if (pId == null || pId.isEmpty) continue;

        final ts = data['purchasedAt'];
        if (ts is Timestamp) {
          tempMap[pId] = ts.toDate();
        }
      }

      purchasedPlanDates.value = tempMap;
    } catch (e) {
      print("Error fetching purchased plans: $e");
      purchasedPlanDates.value = {};
    }
  }

  // 3️⃣ Check if Plan is Active or Expired
  // Returns true if purchasedPlanDates contains EITHER (as String):
  // (1) Firestore plan document ID (Stripe/in-app), OR (2) plan['wooProductId'] (WooCommerce).
  bool isPlanActive(Map<String, dynamic> plan) {
    final String? planId = plan['id']?.toString().trim();
    final Object? wooId = plan['wooProductId'] ?? plan['woo_product_id'];
    final String? wooIdStr = wooId?.toString().trim();
    if ((planId == null || planId.isEmpty) && (wooIdStr == null || wooIdStr.isEmpty)) return false;

    String? key;
    if (planId != null && purchasedPlanDates.containsKey(planId)) {
      key = planId;
    } else if (wooIdStr != null && purchasedPlanDates.containsKey(wooIdStr)) {
      key = wooIdStr;
    } else {
      return false;
    }

    final DateTime purchaseDate = purchasedPlanDates[key]!;
    final int durationVal = (plan['durationValue'] is int) ? plan['durationValue'] as int : int.tryParse(plan['durationValue']?.toString() ?? '0') ?? 0;
    final String durationUnit = plan['durationUnit']?.toString().trim().toLowerCase() ?? 'weeks';

    final DateTime now = DateTime.now();
    if (durationVal == 0) return true; // Lifetime

    final DateTime expiryDate;
    if (durationUnit.contains('day')) {
      expiryDate = purchaseDate.add(Duration(days: durationVal));
    } else if (durationUnit.contains('week')) {
      expiryDate = purchaseDate.add(Duration(days: durationVal * 7));
    } else if (durationUnit.contains('month')) {
      expiryDate = DateTime(purchaseDate.year, purchaseDate.month + durationVal, purchaseDate.day);
    } else if (durationUnit.contains('year')) {
      expiryDate = DateTime(purchaseDate.year + durationVal, purchaseDate.month, purchaseDate.day);
    } else {
      expiryDate = purchaseDate.add(Duration(days: durationVal));
    }

    return now.isBefore(expiryDate);
  }

  // 3️⃣ Free Plan Join Logic
  Future<void> joinFreePlan(Map<String, dynamic> plan) async {
    await _activatePlanForUser(plan);
  }

  /// 4️⃣ 💰 PAID PLAN PURCHASE LOGIC (STRIPE) — disabled for testing; use test bypass below
  Future<void> purchasePlan(Map<String, dynamic> plan) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Login Required', 'Please login to purchase a plan', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    //isLoading.value = true;

    try {
      print("🔵 STARTING PAYMENT FOR: ${plan['title']} - \$${plan['priceValue']}");

      // 1. Create Payment Intent
      // Convert dollars to cents (Example: $40.0 -> 4000 cents)
      String amountCents = (plan['priceValue'] * 100).toInt().toString();

      Map<String, dynamic> paymentIntent = await _createPaymentIntent(amountCents, 'usd');

      if (paymentIntent['clientSecret'] == null) {
        throw Exception("Client Secret is NULL! Check Backend.");
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['clientSecret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Fitness Life',
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF8B0000),
              background: Color(0xFF1C1C1E),
              componentBackground: Color(0xFF2C2C2E),
              componentText: Colors.white,
              primaryText: Colors.white,
              secondaryText: Colors.grey,
              placeholderText: Colors.white38,
              icon: Colors.white,
            ),
          ),
        ),
      );

      print("🟡 SHEET INITIALIZED. OPENING NOW...");

      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print("✅ PAYMENT SUCCESSFUL");

      // 4. Activate Plan in Firestore
      await _activatePlanForUser(plan);

      // 5. Send welcome email via Vercel backend (Resend) — fire-and-forget
      _sendWelcomeEmailAfterPurchase(plan);

      Get.snackbar(
        'Success! 🎉',
        'Payment successful! ${plan['title']} is now active.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } on StripeException catch (e) {
      print("🔴 STRIPE ERROR: ${e.error.localizedMessage}");
      if (e.error.code == FailureCode.Canceled) {
        Get.snackbar('Cancelled', 'Payment cancelled', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Payment failed: ${e.error.localizedMessage}', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("🔴 GENERAL ERROR: $e");
      Get.snackbar('Error', 'Payment failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      //isLoading.value = false;
    }
  }

  /// 4️⃣ 💰 TEMPORARY TEST FUNCTION (Stripe Bypass) — currently active for testing
 /* Future<void> purchasePlan(Map<String, dynamic> plan) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Login Required', 'Please login to purchase a plan', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      print("🔵 TESTING MODE: Bypassing Stripe Payment...");

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF8B0000)),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(seconds: 3));
      if (Get.isDialogOpen ?? false) Get.back();

      print("✅ FAKE PAYMENT SUCCESSFUL");

      await _activatePlanForUser(plan);
      _sendWelcomeEmailAfterPurchase(plan);

      Get.snackbar(
        'Success! 🎉',
        'Payment successful! ${plan['title']} is now active.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error: $e");
      Get.snackbar('Error', 'Test purchase failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
*/

  /// Calls Vercel backend to send welcome email via Resend (after purchase success).
  /// Does not block UI; failures are logged only.
  void _sendWelcomeEmailAfterPurchase(Map<String, dynamic> plan) {
    final String? email = _auth.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      print('⚠️ Welcome email SKIPPED: user has no email (e.g. signed in with phone). Add email in Firebase Auth to receive emails.');
      return;
    }

    final String planTitle = plan['title']?.toString().trim() ?? 'Your Plan';
    final Object? priceVal = plan['priceValue'] ?? plan['price'];
    final double? price = priceVal is num ? priceVal.toDouble() : (priceVal != null ? double.tryParse(priceVal.toString()) : null);
    final String url = '$backendUrl/send-welcome-email';
    print('📧 Sending welcome email to $email via $url');

    http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'planTitle': planTitle,
        if (price != null) 'price': price,
      }),
    ).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Welcome email sent to $email');
      } else {
        print('⚠️ Welcome email failed: status=${response.statusCode} body=${response.body}');
        if (response.statusCode == 404) {
          print('   → Add api/send-welcome-email.js to your Vercel stripe-backend and redeploy.');
        } else if (response.statusCode == 500) {
          print('   → Set RESEND_API_KEY in Vercel Project → Settings → Environment Variables.');
        }
      }
    }).catchError((err) {
      print('⚠️ Welcome email request error: $err');
      print('   → Check: 1) Vercel route deployed? 2) Device has internet?');
    });
  }

  /// 1️⃣ Fetch Progress for a Specific Plan
  void fetchPlanProgress(String planId) async {
    String uid = _auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    try {
      // A. Get Start Date from Assignment
      var assignmentDoc = await _db.collection('workout_plan_assignments').doc(planId).get();
      if (assignmentDoc.exists) {
        List assignedUsers = assignmentDoc.data()?['assignedUsers'] ?? [];
        if (assignedUsers.contains(uid)) {
          // If you stored a specific join date for the user, retrieve it here.
          // For now, we assume 'lastUpdated' is the start date or default to now.
          Timestamp? ts = assignmentDoc.data()?['lastUpdated'];
          planStartDate.value = ts?.toDate() ?? DateTime.now();
        }
      }

      // B. Get Completed Dates
      var progressDoc = await _db.collection('user_progress').doc('${uid}_$planId').get();
      if (progressDoc.exists) {
        List<dynamic> dates = progressDoc.data()?['completedDates'] ?? [];
        completedDates.value = dates.map((d) => (d as Timestamp).toDate()).toList();
      } else {
        completedDates.clear();
      }
    } catch (e) {
      print("Error fetching progress: $e");
    }
  }

  // 2️⃣ Mark Today as Complete (Toggle)
  Future<void> markTodayComplete(String planId) async {
    String uid = _auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    DateTime now = DateTime.now();
    // Normalize date to remove time (so we only compare Day/Month/Year)
    DateTime today = DateTime(now.year, now.month, now.day);

    bool exists = completedDates.any((d) =>
    d.year == today.year && d.month == today.month && d.day == today.day
    );

    List<DateTime> newDates = List.from(completedDates);

    if (exists) {
      // Remove if already marked (Untick)
      newDates.removeWhere((d) => d.year == today.year && d.month == today.month && d.day == today.day);
    } else {
      // Add if not marked
      newDates.add(today);
    }

    try {
      // Save to Firestore
      await _db.collection('user_progress').doc('${uid}_$planId').set({
        'completedDates': newDates.map((d) => Timestamp.fromDate(d)).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update Local State
      completedDates.value = newDates;
      Get.snackbar(
          exists ? "Undone" : "Great Job!",
          exists ? "Progress removed for today." : "Workout marked as complete!",
          backgroundColor: exists ? Colors.orange : Colors.green,
          colorText: Colors.white
      );
    } catch (e) {
      print("Error saving progress: $e");
    }
  }

  // Helper to check if a specific date is done
  bool isDateCompleted(DateTime date) {
    return completedDates.any((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day
    );
  }

  // --- HELPER: Create Payment Intent ---
  Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        body: {
          'amount': amount,
          'currency': currency,
        },
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  // --- HELPER: Activate Plan & Grant Access to Exercises ---
  // ✅ 2. Activate Plan & Save Date correctly
  Future<void> _activatePlanForUser(Map<String, dynamic> plan) async {
    try {
      // Loader બતાવો
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000))),
        barrierDismissible: false,
      );

      String planId = plan['id'];
      String planTitle = plan['title'];
      String uid = _auth.currentUser?.uid ?? "";

      if (uid.isEmpty) {
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }

      // Step A: workout_plan_assignments માં યુઝરને એડ કરો
      // (આ માત્ર એક્સેસ માટે છે, તારીખ માટે નહિ)
      await _db.collection('workout_plan_assignments').doc(planId).set({
        'planId': planId,
        'planName': planTitle,
        'assignedUsers': FieldValue.arrayUnion([uid]),
        // 'lastUpdated': ... આ લાઈન હવે જરૂર નથી, કાઢી નાખો તો પણ ચાલે
      }, SetOptions(merge: true));

      // Step B: User Purchases માં હંમેશા એન્ટ્રી કરો (Free હોય તો પણ!)
      // 👇 આનાથી જ હવે Expiry ગણાશે
      await _db.collection('user_purchases').doc(uid).collection('plans').add({
        'planId': planId,
        'planTitle': planTitle,
        'price': plan['priceValue'] ?? 0,
        'purchasedAt': FieldValue.serverTimestamp(), // ✅ સાચી ખરીદીની તારીખ
        'status': 'active'
      });

      // Step C: Exercise Visibility સેટ કરો (તમારો જૂનો કોડ)
      var planDoc = await _db.collection('workout_plans').doc(planId).get();
      if (planDoc.exists) {
        List<dynamic> exercisesData = planDoc.data()?['exercises'] ?? [];
        for (var exData in exercisesData) {
          String exId = exData['exerciseId'].toString();
          String exName = exData['exerciseName'] ?? "Unknown";

          final visDocRef = _db.collection('exercise_visibility').doc(exId);
          final visDoc = await visDocRef.get();

          if (visDoc.exists) {
            await visDocRef.update({
              'visibleForUsers': FieldValue.arrayUnion([uid]),
            });
          } else {
            await visDocRef.set({
              'exerciseId': exId,
              'exerciseName': exName,
              'isVisibleToAll': false,
              'visibleForUsers': [uid],
              'controlledBy': 'system',
            });
          }
        }
      }

      // Refresh UI
      await fetchPurchasedPlans();

      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Success", "Plan Activated!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error activating plan: $e");
    }
  }
}





///new Approcch
// class PlanController extends GetxController {
//   // --------------------------------------------------------
//   // STRIPE CONFIG
//   // --------------------------------------------------------
//   static const String publishableKey = 'pk_test_51OZ2XxKItFmRol0wM4Vi7Ooo0I54PTP0SUbzLOaQ46Qf0neAwM2noZHGc5eDHiZt2PwWthQM1KiUzn21CqqnSB2S00DJwnz942';
//   static const String backendUrl = 'https://stripe-backend-sigma.vercel.app/api';
//
//   var isLoading = false.obs;
//
//   // Firebase Plans
//   var workoutPlans = <WorkoutPlan>[].obs;
//   var isWorkoutLoading = true.obs;
//
//   // User Purchases
//   var purchasedPlanTitles = <String>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     Stripe.publishableKey = publishableKey;
//     fetchPurchasedPlans();
//     _bindWorkoutPlansStream();
//   }
//
//   // 1. Firebase માંથી Workout Plans લાવવા
//   void _bindWorkoutPlansStream() {
//     isWorkoutLoading.value = true;
//
//     // આખા એપમાં બધા જ પ્લાન બતાવવા માટે (Shop જેવું)
//     // અથવા જો તમારે ફક્ત assigned બતાવવા હોય તો query બદલવી પડે.
//     // અત્યારે આપણે બધા પ્લાન બતાવીએ છીએ જેથી યુઝર ખરીદી શકે.
//     FirebaseFirestore.instance
//         .collection('workout_plans')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       workoutPlans.value = snapshot.docs
//           .map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id))
//           .toList();
//       isWorkoutLoading.value = false;
//     });
//   }
//
//   // 2. યુઝરે શું ખરીદ્યું છે તે ચેક કરવું
//   void fetchPurchasedPlans() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('user_purchases')
//           .doc(userId)
//           .collection('plans')
//           .get();
//
//       purchasedPlanTitles.value = snapshot.docs
//           .map((doc) => doc['planTitle'].toString().trim())
//           .toList();
//
//       print("📦 Purchased: $purchasedPlanTitles");
//     } catch (e) {
//       print("Error fetching purchases: $e");
//     }
//   }
//
//   // 3. Purchase Function specifically for WorkoutPlan Object
//   Future<void> purchaseWorkoutPlan(WorkoutPlan plan) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) {
//       Get.snackbar('Login Required', 'Please login first', backgroundColor: Colors.orange);
//       return;
//     }
//
//     // Check if already active
//     if (purchasedPlanTitles.contains(plan.name.trim())) {
//       Get.snackbar('Active', 'You already own this plan!', backgroundColor: Colors.blue, colorText: Colors.white);
//       return;
//     }
//
//     isLoading.value = true;
//
//     // 🔥 STATIC PRICE SETTING (અહીંયા ફિક્સ $40 રાખ્યું છે)
//     double staticPrice = 40.0;
//
//     try {
//       String amountCents = (staticPrice * 100).toInt().toString(); // $40.00
//
//       // 1. Stripe Intent
//       Map<String, dynamic> paymentIntent = await _createPaymentIntent(amountCents, 'usd');
//
//       // 2. Init Sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent['clientSecret'],
//           style: ThemeMode.dark,
//           merchantDisplayName: 'Fitness Life',
//           appearance: const PaymentSheetAppearance(
//             colors: PaymentSheetAppearanceColors(
//               primary: Color(0xFF8B0000),
//             ),
//           ),
//         ),
//       );
//
//       // 3. Show Sheet
//       await Stripe.instance.presentPaymentSheet();
//
//       // 4. Save Success
//       await _savePurchaseToFirestore(plan.name, staticPrice, userId);
//
//       Get.snackbar('Success! 🎉', 'You have unlocked ${plan.name}', backgroundColor: Colors.green, colorText: Colors.white);
//
//     } catch (e) {
//       print("Payment Error: $e");
//       Get.snackbar('Cancelled', 'Payment process cancelled', backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
//     try {
//       final response = await http.post(
//         Uri.parse(backendUrl),
//         body: {'amount': amount, 'currency': currency},
//       );
//       return json.decode(response.body);
//     } catch (err) {
//       throw Exception(err.toString());
//     }
//   }
//
//   Future<void> _savePurchaseToFirestore(String planTitle, double price, String userId) async {
//     await FirebaseFirestore.instance
//         .collection('user_purchases')
//         .doc(userId)
//         .collection('plans')
//         .add({
//       'planTitle': planTitle,
//       'price': price,
//       'purchasedAt': FieldValue.serverTimestamp(),
//       'status': 'active',
//     });
//     purchasedPlanTitles.add(planTitle.trim()); // UI Update immediately
//   }
// }