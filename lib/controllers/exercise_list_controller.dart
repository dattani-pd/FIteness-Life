// import 'package:get/get.dart';
// import '../services/api.dart';
// import 'package:get/get.dart';
//
//
// class ExerciseListController extends GetxController {
//   final WorkoutApiService _apiService = WorkoutApiService();
//
//   var isLoading = true.obs;
//   var exerciseList = [].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchExercises();
//   }
//
//   Future<void> fetchExercises() async {
//     try {
//       isLoading.value = true;
//       var result = await _apiService.getExercises();
//       if (result != null) {
//         exerciseList.value = result;
//       }
//     } catch (e) {
//       print("Error: $e");
//       Get.snackbar("Error", "Could not fetch exercises");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // Needed for rootBundle
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'package:flutter/services.dart'; // Required for rootBundle
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseListController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  var isLoading = true.obs;
  var exerciseList = [].obs;
  var allExercises = []; // Backup for searching

  @override
  void onInit() {
    super.onInit();
    loadData(); // Call the fixed name
  }

  // --- RENAMED FROM loadLocalData TO loadData TO MATCH YOUR BUTTON ---
  void loadData() async {
    try {
      isLoading.value = true;

      // 1. Load the JSON file from assets
      // Make sure 'assets/json/exercises.json' exists and is in pubspec.yaml
      final String response = await rootBundle.loadString('assets/json/exercises.json');

      // 2. Decode JSON
      final data = await json.decode(response);

      if (data is List) {
        exerciseList.value = data;
        allExercises = data;
      }
    } catch (e) {
      print("Error loading local file: $e");
      Get.snackbar("Error", "Could not load data. Check assets folder.");
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      exerciseList.value = allExercises;
      return;
    }
    // Instant Local Search
    var filtered = allExercises.where((ex) {
      return ex['name'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();
    exerciseList.value = filtered;
  }

  void clearSearch() {
    searchController.clear();
    exerciseList.value = allExercises;
  }
}