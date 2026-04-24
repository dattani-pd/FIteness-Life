// ==========================================
// 3. NEW: Exercise Visibility Controller (For Trainers)
// ==========================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==============================================================================
// EXERCISE VISIBILITY CONTROLLER - LOAD ALL USERS VERSION
// ==============================================================================
class ExerciseVisibilityController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var myStudents = <Map<String, dynamic>>[].obs;
  var isLoadingStudents = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMyStudents();
  }

  // ==============================================================================
  // LOAD ALL USERS WITH ROLE = 'user' (NO TRAINER FILTER)
  // ==============================================================================
  Future<void> _loadMyStudents() async {
    try {
      isLoadingStudents.value = true;
      print("🔍 Loading all users with role='user'...");

      // Get ALL users where role = 'user'
      var snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      print("📊 Found ${snapshot.docs.length} users");

      if (snapshot.docs.isEmpty) {
        print("❌ No users found in database");
        Get.snackbar(
          "No Students",
          "No users with role='user' found in database",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Process all users
      myStudents.value = snapshot.docs.map((doc) {
        var data = doc.data();

        String email = data['email'] ?? 'No Email';
        String name = email.split('@')[0]; // Use email prefix as name

        print("👤 Loaded: $name ($email) - UID: ${doc.id}");

        return {
          'uid': doc.id,
          'name': name,
          'email': email,
        };
      }).toList();

      print("✅ Successfully loaded ${myStudents.length} students");

    } catch (e) {
      print("❌ Error loading students: $e");
      Get.snackbar(
        "Error",
        "Failed to load students: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // ==============================================================================
  // CHECK IF EXERCISE IS VISIBLE TO SPECIFIC USER (STREAM)
  // ==============================================================================
  Stream<bool> isExerciseVisibleStream(String exerciseId, String studentUid) {
    return _db
        .collection('exercise_visibility')
        .doc(exerciseId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        print("📄 No visibility doc for $exerciseId - default visible");
        return true; // Default: visible to everyone
      }

      var data = doc.data()!;
      bool isVisibleToAll = data['isVisibleToAll'] ?? true;

      print("📄 Exercise $exerciseId - isVisibleToAll: $isVisibleToAll");

      if (isVisibleToAll) {
        return true; // Globally visible
      } else {
        List visibleForUsers = data['visibleForUsers'] ?? [];
        bool isVisible = visibleForUsers.contains(studentUid);
        print("   Student $studentUid - isVisible: $isVisible (in list: $visibleForUsers)");
        return isVisible;
      }
    });
  }

  // ==============================================================================
  // SET EXERCISE VISIBILITY FOR SPECIFIC USER
  // ==============================================================================
  Future<void> setExerciseVisibilityForUser(
      String exerciseId,
      String exerciseName,
      String studentUid,
      bool shouldBeVisible,
      ) async {
    try {
      print("🔧 Setting visibility: $exerciseName");
      print("   Exercise ID: $exerciseId");
      print("   Student UID: $studentUid");
      print("   Should be visible: $shouldBeVisible");

      var docRef = _db.collection('exercise_visibility').doc(exerciseId);
      var doc = await docRef.get();

      if (!doc.exists) {
        // Create new document
        await docRef.set({
          'exerciseId': exerciseId,
          'exerciseName': exerciseName,
          'isVisibleToAll': false, // Restricted access
          'visibleForUsers': shouldBeVisible ? [studentUid] : [],
          'controlledBy': _auth.currentUser?.uid,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print("✅ Created new visibility document");
      } else {
        // Update existing document
        var data = doc.data()!;
        List visibleForUsers = List.from(data['visibleForUsers'] ?? []);

        print("   Current visibleForUsers: $visibleForUsers");

        if (shouldBeVisible) {
          if (!visibleForUsers.contains(studentUid)) {
            visibleForUsers.add(studentUid);
            print("   Added $studentUid to list");
          }
        } else {
          visibleForUsers.remove(studentUid);
          print("   Removed $studentUid from list");
        }

        await docRef.update({
          'visibleForUsers': visibleForUsers,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print("✅ Updated visibility document");
        print("   New visibleForUsers: $visibleForUsers");
      }

    } catch (e) {
      print("❌ Error setting visibility: $e");
      Get.snackbar(
        "Error",
        "Failed to update: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==============================================================================
  // TOGGLE EXERCISE FOR USER
  // ==============================================================================
  Future<void> toggleExerciseForUser(
      String exerciseId,
      String exerciseName,
      String studentUid,
      ) async {
    try {
      print("🔄 Toggling visibility for $exerciseName - Student: $studentUid");

      bool currentlyVisible = await isExerciseVisibleStream(exerciseId, studentUid).first;
      print("   Currently visible: $currentlyVisible");
      print("   Will set to: ${!currentlyVisible}");

      await setExerciseVisibilityForUser(
        exerciseId,
        exerciseName,
        studentUid,
        !currentlyVisible,
      );

      Get.snackbar(
        currentlyVisible ? "Hidden" : "Visible",
        currentlyVisible
            ? "Exercise hidden from this student"
            : "Exercise now visible to this student",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: currentlyVisible ? Colors.orange : Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("❌ Error toggling: $e");
    }
  }

  // ==============================================================================
  // MANUAL REFRESH
  // ==============================================================================
  Future<void> refreshStudents() async {
    await _loadMyStudents();
  }

  // ==============================================================================
  // GET VISIBLE STUDENTS
  // ==============================================================================
  Future<List<String>> getVisibleStudents(String exerciseId) async {
    try {
      var doc = await _db.collection('exercise_visibility').doc(exerciseId).get();

      if (!doc.exists) {
        return myStudents.map((s) => s['uid'] as String).toList();
      }

      var data = doc.data()!;
      bool isVisibleToAll = data['isVisibleToAll'] ?? true;

      if (isVisibleToAll) {
        return myStudents.map((s) => s['uid'] as String).toList();
      } else {
        return List<String>.from(data['visibleForUsers'] ?? []);
      }
    } catch (e) {
      print("❌ Error getting visible students: $e");
      return [];
    }
  }

  // ==============================================================================
  // RESET VISIBILITY
  // ==============================================================================
  Future<void> resetExerciseVisibility(String exerciseId) async {
    try {
      await _db.collection('exercise_visibility').doc(exerciseId).delete();
      print("✅ Reset visibility for $exerciseId");

      Get.snackbar(
        "Reset",
        "Exercise is now visible to all students",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print("❌ Error resetting: $e");
    }
  }

  // ==============================================================================
  // CHECK IF HAS RESTRICTIONS
  // ==============================================================================
  Future<bool> hasRestrictions(String exerciseId) async {
    try {
      var doc = await _db.collection('exercise_visibility').doc(exerciseId).get();

      if (!doc.exists) return false;

      var data = doc.data()!;
      bool isVisibleToAll = data['isVisibleToAll'] ?? true;

      return !isVisibleToAll;
    } catch (e) {
      print("❌ Error checking restrictions: $e");
      return false;
    }
  }
}