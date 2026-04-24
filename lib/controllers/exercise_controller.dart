import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/constant.dart';
import '../model/model.dart';

// class ExerciseController extends GetxController {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Text Controllers for "Add Exercise" Form
//   final nameController = TextEditingController();
//   final muscleController = TextEditingController();
//   final videoUrlController = TextEditingController();
//   final instructionsController = TextEditingController();
//
//   var isLoading = false.obs;
//   var exerciseList = <ExerciseModel>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchExercises(); // Load data when app starts
//   }
//
//   // --- 1. ADD EXERCISE (Admin/Trainer Only) ---
//   Future<void> addExercise() async {
//     if (nameController.text.isEmpty || muscleController.text.isEmpty) {
//       Get.snackbar("Error", "Please fill required fields");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       // Create a unique ID
//       String newId = _db.collection('exercises').doc().id;
//
//       ExerciseModel newExercise = ExerciseModel(
//         id: newId,
//         name: nameController.text.trim(),
//         muscleGroup: muscleController.text.trim(),
//         videoUrl: videoUrlController.text.trim(), // In future, we upload video file here
//         instructions: instructionsController.text.trim(),
//         createdBy: AppConstants.userId,
//       );
//
//       // Save to Firestore
//       await _db.collection('exercises').doc(newId).set(newExercise.toMap());
//
//       isLoading.value = false;
//       Get.back(); // Close screen
//       Get.snackbar("Success", "Exercise Added!");
//
//       // Clear fields
//       nameController.clear();
//       muscleController.clear();
//       videoUrlController.clear();
//       instructionsController.clear();
//
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar("Error", e.toString());
//     }
//   }
//
//   // --- 2. FETCH EXERCISES (For Everyone) ---
//   void fetchExercises() {
//     _db.collection('exercises').snapshots().listen((snapshot) {
//       exerciseList.value = snapshot.docs
//           .map((doc) => ExerciseModel.fromMap(doc.data(), doc.id))
//           .toList();
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/exercise_model.dart'; // Ensure correct import


class ExerciseController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Auth Instance

  // Text Controllers for "Add Exercise" Form
  final nameController = TextEditingController();
  final muscleController = TextEditingController();
  final videoUrlController = TextEditingController();
  final instructionsController = TextEditingController();

  var isLoading = false.obs;
  var exerciseList = <ExerciseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchExercises(); // Load data when app starts
  }

  // --- 1. ADD EXERCISE (Admin/Trainer Only) ---
  Future<void> addExercise() async {
    if (nameController.text.isEmpty || muscleController.text.isEmpty) {
      Get.snackbar("Error", "Please fill Exercise Name and Muscle Group", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // ✅ Get Current User ID safely
      String? currentUid = _auth.currentUser?.uid;
      if (currentUid == null) {
        Get.snackbar("Error", "User not logged in");
        isLoading.value = false;
        return;
      }

      // Create a unique ID
      String newId = _db.collection('exercises').doc().id;

      // ✅ Use Map directly to ensure compatibility
      Map<String, dynamic> exerciseData = {
        'id': newId,
        'name': nameController.text.trim(),
        'muscleGroup': muscleController.text.trim(),
        'videoUrl': videoUrlController.text.trim(),
        'instructions': instructionsController.text.trim(),
        'createdBy': currentUid,
        'createdAt': FieldValue.serverTimestamp(), // ✅ Timestamp added
      };

      // Save to Firestore
      await _db.collection('exercises').doc(newId).set(exerciseData);

      isLoading.value = false;
      Get.back(); // Close screen
      Get.snackbar("Success", "Exercise Added Successfully!", backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      nameController.clear();
      muscleController.clear();
      videoUrlController.clear();
      instructionsController.clear();

    } catch (e) {
      print("Error adding exercise: $e"); // ✅ Debug print
      isLoading.value = false;
      Get.snackbar("Error", "Failed to add exercise: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 2. FETCH EXERCISES (For Everyone) ---
  void fetchExercises() {
    _db.collection('exercises')
        .orderBy('createdAt', descending: true) // ✅ Show newest first
        .snapshots()
        .listen((snapshot) {
      exerciseList.value = snapshot.docs
          .map((doc) => ExerciseModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
