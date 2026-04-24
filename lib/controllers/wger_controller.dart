import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/constant.dart';
import '../services/api.dart';
import 'dart:isolate';
import 'package:flutter/foundation.dart';


class WgerController extends GetxController {
  final WgerApiService _apiService = WgerApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var exerciseList = <Map<String, dynamic>>[].obs;
  var categoryList = <Map<String, dynamic>>[].obs;
  var selectedCategoryId = Rxn<int>();

  var muscleList = <Map<String, dynamic>>[].obs;
  var equipmentList = <Map<String, dynamic>>[].obs;

  // NEW: Track hidden exercises for trainers/admins
  var hiddenExerciseIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWgerData();
    // Load hidden exercises for trainers/admins
    if (AppConstants.role == 'trainer' || AppConstants.role == 'admin') {
      _listenToHiddenExercises();
    }
  }

  // *** THE FIX: USE SNAPSHOTS (Real-time Stream) ***
  void _listenToHiddenExercises() {
    try {
      _db
          .collection('exercise_visibility')
          .where('isVisibleToAll', isEqualTo: false)
          .snapshots() // <--- THIS IS THE KEY CHANGE
          .listen((snapshot) {

        // Update the list whenever Firestore changes
        hiddenExerciseIds.value = snapshot.docs
            .map((doc) => doc.id)
            .toList();

        // Force the list to refresh so UI updates
        hiddenExerciseIds.refresh();

        // Also refresh the main exercise list UI to reflect changes
        exerciseList.refresh();

      }, onError: (e) {
        print("Error listening to hidden exercises: $e");
      });

    } catch (e) {
      print("Error setting up listener: $e");
    }
  }

  // NEW: Check if an exercise is hidden
  bool isHidden(int exerciseId) {
    return hiddenExerciseIds.contains(exerciseId.toString());
  }

  // NEW: Toggle exercise visibility (for trainers/admins)
  Future<void> toggleExerciseVisibility(int exerciseId) async {
    try {
      String currentRole = AppConstants.role;
      if (currentRole != 'trainer' && currentRole != 'admin') {
        Get.snackbar("Access Denied", "Only trainers and admins can manage visibility");
        return;
      }

      String exerciseIdStr = exerciseId.toString();
      var docRef = _db.collection('exercise_visibility').doc(exerciseIdStr);
      var doc = await docRef.get();

      // Find exercise name from current list
      var exercise = exerciseList.firstWhere(
            (ex) => ex['id'] == exerciseId,
        orElse: () => {'name': 'Unknown Exercise'},
      );

      if (!doc.exists) {
        // Create new rule - hide the exercise
        await docRef.set({
          'exerciseId': exerciseIdStr,
          'exerciseName': exercise['name'],
          'isVisibleToAll': false,
          'hiddenForUsers': [],
          'visibleOnlyFor': [],
          'controlledBy': _auth.currentUser!.uid,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        hiddenExerciseIds.add(exerciseIdStr);
        Get.snackbar(
          "Hidden",
          "${exercise['name']} is now hidden from all users",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Toggle existing rule
        bool currentVisibility = doc.data()?['isVisibleToAll'] ?? true;

        await docRef.update({
          'isVisibleToAll': !currentVisibility,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (currentVisibility) {
          // Was visible, now hidden
          hiddenExerciseIds.add(exerciseIdStr);
          Get.snackbar(
            "Hidden",
            "${exercise['name']} is now hidden from all users",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          // Was hidden, now visible
          hiddenExerciseIds.remove(exerciseIdStr);
          Get.snackbar(
            "Visible",
            "${exercise['name']} is now visible to all users",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update visibility: $e");
      print("Error toggling visibility: $e");
    }
  }

  void loadWgerData() async {
    try {
      isLoading.value = true;
      exerciseList.clear();
      categoryList.clear();

      var categories = await _apiService.getCategories();
      categoryList.assignAll(categories.map((cat) => {
        "id": cat['id'],
        "name": cat['name'],
      }).toList());

      var muscles = await _apiService.getMuscles();
      muscleList.assignAll(muscles.map((m) => {
        "id": m['id'],
        "name": m['name'],
        "name_en": m['name_en'],
      }).toList());

      var equipment = await _apiService.getEquipment();
      equipmentList.assignAll(equipment.map((eq) => {
        "id": eq['id'],
        "name": eq['name'],
      }).toList());

      var exercises = await _apiService.getExercises();
      final processedData = await compute(_processExercisesInIsolate, exercises);

      // *** APPLY VISIBILITY FILTER ***
      final visibleExercises = await _filterExercisesByVisibility(processedData);

      exerciseList.assignAll(visibleExercises);
      print("✅ Loaded ${visibleExercises.length} visible exercises");

    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar("Error", "Could not load data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // *** Filter exercises based on user role and visibility rules ***
  Future<List<Map<String, dynamic>>> _filterExercisesByVisibility(
      List<Map<String, dynamic>> exercises) async {

    String currentRole = AppConstants.role;
    String currentUid = _auth.currentUser!.uid;

    // ADMINS and TRAINERS see everything
    if (currentRole == 'admin' || currentRole == 'trainer') {
      return exercises;
    }

    // USERS: Apply visibility filters
    try {
      // Get all visibility rules from Firestore
      var visibilitySnapshot = await _db.collection('exercise_visibility').get();

      Map<String, Map<String, dynamic>> visibilityRules = {};
      for (var doc in visibilitySnapshot.docs) {
        visibilityRules[doc.id] = doc.data();
      }

      // Filter exercises
      List<Map<String, dynamic>> filteredExercises = [];

      for (var exercise in exercises) {
        String exerciseId = exercise['id'].toString();

        // Check if there's a visibility rule for this exercise
        if (visibilityRules.containsKey(exerciseId)) {
          var rule = visibilityRules[exerciseId]!;

          // Check if hidden for this user
          List hiddenForUsers = rule['hiddenForUsers'] ?? [];
          if (hiddenForUsers.contains(currentUid)) {
            continue; // Skip this exercise
          }

          // Check if restricted to specific users
          List visibleOnlyFor = rule['visibleOnlyFor'] ?? [];
          if (visibleOnlyFor.isNotEmpty && !visibleOnlyFor.contains(currentUid)) {
            continue; // Skip this exercise
          }

          // Check global visibility
          bool isVisibleToAll = rule['isVisibleToAll'] ?? true;
          if (!isVisibleToAll) {
            continue; // Skip this exercise
          }
        }

        // If no rule or passed all checks, include the exercise
        filteredExercises.add(exercise);
      }

      return filteredExercises;

    } catch (e) {
      print("Error filtering exercises: $e");
      return exercises; // Return all if error
    }
  }

  void filterByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  List<Map<String, dynamic>> get filteredExercises {
    if (selectedCategoryId.value == null) {
      return exerciseList;
    }
    return exerciseList.where((ex) {
      return ex['category_id'] == selectedCategoryId.value;
    }).toList();
  }

  static List<Map<String, dynamic>> _processExercisesInIsolate(List<dynamic> exercises) {
    List<Map<String, dynamic>> cleanList = [];

    for (var ex in exercises) {
      int id = ex['id'];
      String? name;
      String? description;

      if (ex['translations'] != null && ex['translations'] is List) {
        List translations = ex['translations'];
        var englishTranslation = translations.firstWhere(
              (t) => t['language'] == 2,
          orElse: () => translations.isNotEmpty ? translations[0] : null,
        );

        if (englishTranslation != null) {
          name = englishTranslation['name'];
          description = englishTranslation['description'];
        }
      }

      if (name == null || name.isEmpty) {
        if (ex['category'] != null && ex['category'] is Map) {
          name = "${ex['category']['name']} Exercise";
        } else {
          continue;
        }
      }

      String cleanDesc = _cleanDescriptionStatic(description ?? "");

      List<String> imageUrls = [];
      if (ex['images'] != null && ex['images'] is List) {
        for (var img in ex['images']) {
          if (img['image'] != null) {
            imageUrls.add(img['image']);
          }
        }
      }

      List<String> videoUrls = [];
      if (ex['videos'] != null && ex['videos'] is List) {
        for (var vid in ex['videos']) {
          if (vid['video'] != null) {
            videoUrls.add(vid['video']);
          }
        }
      }

      List muscles = [];
      if (ex['muscles'] != null && ex['muscles'] is List) {
        muscles = List.from(ex['muscles']);
      }

      List musclesSecondary = [];
      if (ex['muscles_secondary'] != null && ex['muscles_secondary'] is List) {
        musclesSecondary = List.from(ex['muscles_secondary']);
      }

      List equipment = [];
      if (ex['equipment'] != null && ex['equipment'] is List) {
        equipment = List.from(ex['equipment']);
      }

      if (cleanDesc == "No description available." &&
          imageUrls.isEmpty && videoUrls.isEmpty) {
        continue;
      }

      cleanList.add({
        "id": id,
        "uuid": ex['uuid'],
        "name": name,
        "description": cleanDesc,
        "videoUrls": videoUrls,
        "imageUrls": imageUrls,
        "category": ex['category']?['name'] ?? "General",
        "category_id": ex['category']?['id'],
        "muscles": muscles,
        "muscles_secondary": musclesSecondary,
        "equipment": equipment,
        "created": ex['created'],
        "last_update": ex['last_update'],
        "last_update_global": ex['last_update_global'],
        "variations": ex['variations'],
        "author_history": ex['author_history'],
        "total_authors_history": ex['total_authors_history'],
        "license": ex['license'],
        "license_author": ex['license_author'],
      });
    }

    cleanList.sort((a, b) {
      int scoreA = (a['videoUrls'].length * 3) +
          (a['imageUrls'].length * 2) +
          (a['description'].length > 50 ? 1 : 0);
      int scoreB = (b['videoUrls'].length * 3) +
          (b['imageUrls'].length * 2) +
          (b['description'].length > 50 ? 1 : 0);
      return scoreB.compareTo(scoreA);
    });

    return cleanList;
  }

  static String _cleanDescriptionStatic(String html) {
    if (html.isEmpty) return "No description available.";

    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text.isNotEmpty ? text : "No description available.";
  }
}
