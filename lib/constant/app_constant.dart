
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/controller.dart';
import '../screen/screen.dart';
import '../utils/shared_preferences_helper.dart';


class AppConstants {
   static String userId = "";
   static String email = "";        // <--- NEW
   static String role = "";         // <--- NEW
   static String userName = "";     // Display name for "Hello, Name"
   static final isApproved = false.obs; // <--- NEW (Observable)

   // 🆕 MuscleWiki Cache Keys
   static const String _cacheKeyExercises = "cached_exercises";
   static const String _cacheKeyCategories = "cached_categories";
   static const String _cacheKeyTimestamp = "cache_timestamp";
   static const String _cacheKeyExerciseDetails = "exercise_details_"; // 🆕 Per-exercise cache
   static const int _cacheDurationDays = 7; // Cache expires after 7 days
   static const String _themeKey = "app_theme_mode";
   static var currentThemeMode = ThemeMode.light.obs; // Default to Light

   /// 🔹 Load everything from SharedPreferences into memory
   static Future<void> loadFromPrefs() async {
      userId = await sharedPreferencesHelper.getPrefData("userId") ?? "";
      email = await sharedPreferencesHelper.getPrefData("email") ?? ""; // <--- NEW
      role = await sharedPreferencesHelper.getPrefData("role") ?? "";   // <--- NEW
      userName = await sharedPreferencesHelper.getPrefData("userName") ?? "";

      bool approved = await sharedPreferencesHelper.retrievePrefBoolData("isApproved"); // <--- NEW
      isApproved.value = approved;
   }

   /// Load Theme from Preferences
   static Future<void> loadTheme() async {
      // Assuming you have a helper for SharedPreferences, otherwise use standard:
      final prefs = await SharedPreferences.getInstance();
      String? themeStr = prefs.getString(_themeKey);

      if (themeStr == "dark") {
         currentThemeMode.value = ThemeMode.dark;
      } else {
         currentThemeMode.value = ThemeMode.light;
      }
   }



   // --- SETTERS ---

   /// Save Theme to Preferences
   /// 🔹 Save Theme Selection
   static Future<void> setTheme(String mode) async {
      final prefs = await SharedPreferences.getInstance();

      if (mode == "dark") {
         currentThemeMode.value = ThemeMode.dark;
         Get.changeThemeMode(ThemeMode.dark);
         await prefs.setString(_themeKey, "dark");
      } else {
         currentThemeMode.value = ThemeMode.light;
         Get.changeThemeMode(ThemeMode.light);
         await prefs.setString(_themeKey, "light");
      }
   }

   static Future<void> setUserId(String id) async {
      userId = id;
      await sharedPreferencesHelper.storePrefData("userId", id);
   }

   static Future<void> setEmail(String val) async { // <--- NEW
      email = val;
      await sharedPreferencesHelper.storePrefData("email", val);
   }

   static Future<void> setRole(String val) async { // <--- NEW
      role = val;
      await sharedPreferencesHelper.storePrefData("role", val);
   }

   static Future<void> setApproved(bool val) async { // <--- NEW
      isApproved.value = val;
      await sharedPreferencesHelper.storeBoolPrefData("isApproved", val);
   }

   static Future<void> setUserName(String val) async {
      userName = val;
      await sharedPreferencesHelper.storePrefData("userName", val);
   }


   // ==============================================================================
   // 🆕 MUSCLEWIKI CACHE FUNCTIONS
   // ==============================================================================

   /// Check if cache is valid
   static Future<bool> isCacheValid() async {
      String? timestampStr = await sharedPreferencesHelper.getPrefData(_cacheKeyTimestamp);
      if (timestampStr == null || timestampStr.isEmpty) return false;

      try {
         DateTime cachedTime = DateTime.parse(timestampStr);
         DateTime now = DateTime.now();
         int daysDiff = now.difference(cachedTime).inDays;
         return daysDiff < _cacheDurationDays;
      } catch (e) {
         print("❌ Cache timestamp parse error: $e");
         return false;
      }
   }

   /// Save exercises to cache
   static Future<void> cacheExercises(List<Exercise> exercises) async {
      try {
         List<Map<String, dynamic>> jsonList = exercises.map((e) => _exerciseToJson(e)).toList();
         String jsonString = json.encode(jsonList);
         await sharedPreferencesHelper.storePrefData(_cacheKeyExercises, jsonString);

         await sharedPreferencesHelper.storePrefData(
            _cacheKeyTimestamp,
            DateTime.now().toIso8601String(),
         );
         print("✅ Cached ${exercises.length} exercises");
      } catch (e) {
         print("❌ Cache save error: $e");
      }
   }

   /// Load exercises from cache
   static Future<List<Exercise>?> getCachedExercises() async {
      try {
         String? jsonString = await sharedPreferencesHelper.getPrefData(_cacheKeyExercises);
         if (jsonString == null || jsonString.isEmpty) return null;

         List<dynamic> jsonList = json.decode(jsonString);
         List<Exercise> exercises = jsonList.map((json) => Exercise.fromJson(json)).toList();
         print("✅ Loaded ${exercises.length} exercises from cache");
         return exercises;
      } catch (e) {
         print("❌ Cache load error: $e");
         return null;
      }
   }

   // 🆕 CACHE DETAILED EXERCISE DATA
   static Future<void> cacheExerciseDetail(int exerciseId, Map<String, dynamic> detailData) async {
      try {
         String jsonString = json.encode(detailData);
         await sharedPreferencesHelper.storePrefData('$_cacheKeyExerciseDetails$exerciseId', jsonString);
         print("✅ Cached details for exercise $exerciseId");
      } catch (e) {
         print("❌ Detail cache error: $e");
      }
   }

   // 🆕 GET CACHED EXERCISE DETAILS
   static Future<Map<String, dynamic>?> getCachedExerciseDetail(dynamic exerciseId) async {
      try {
         String? jsonString = await sharedPreferencesHelper.getPrefData('$_cacheKeyExerciseDetails$exerciseId');
         if (jsonString == null || jsonString.isEmpty) return null;

         Map<String, dynamic> detailData = json.decode(jsonString);
         print("✅ Loaded cached details for exercise $exerciseId");
         return detailData;
      } catch (e) {
         print("❌ Detail load error: $e");
         return null;
      }
   }

   /// Save categories to cache
   static Future<void> cacheCategories(List<CategoryItem> categories) async {
      try {
         List<Map<String, dynamic>> jsonList = categories
             .map((c) => {'name': c.name, 'displayName': c.displayName})
             .toList();
         String jsonString = json.encode(jsonList);
         await sharedPreferencesHelper.storePrefData(_cacheKeyCategories, jsonString);
         print("✅ Cached ${categories.length} categories");
      } catch (e) {
         print("❌ Category cache error: $e");
      }
   }

   /// Load categories from cache
   static Future<List<CategoryItem>?> getCachedCategories() async {
      try {
         String? jsonString = await sharedPreferencesHelper.getPrefData(_cacheKeyCategories);
         if (jsonString == null || jsonString.isEmpty) return null;

         List<dynamic> jsonList = json.decode(jsonString);
         List<CategoryItem> categories = jsonList
             .map((json) => CategoryItem(
            name: json['name'] ?? '',
            displayName: json['displayName'] ?? '',
         ))
             .toList();
         print("✅ Loaded ${categories.length} categories from cache");
         return categories;
      } catch (e) {
         print("❌ Category cache load error: $e");
         return null;
      }
   }

   /// Clear MuscleWiki cache
   static Future<void> clearMuscleWikiCache() async {
      await sharedPreferencesHelper.storePrefData(_cacheKeyExercises, "");
      await sharedPreferencesHelper.storePrefData(_cacheKeyCategories, "");
      await sharedPreferencesHelper.storePrefData(_cacheKeyTimestamp, "");
      // Note: Individual exercise details are kept for offline access
      print("✅ MuscleWiki cache cleared");
   }

   /// Helper: Convert Exercise to JSON
   static Map<String, dynamic> _exerciseToJson(Exercise e) {
      return {
         'id': e.id,
         'name': e.name,
         'category': e.category,
         'difficulty': e.difficulty,
         'description': e.description,
         'steps': e.steps,
         'imageUrl': e.imageUrl,
         'videoUrl': e.videoUrl,
         'targetMuscles': e.targetMuscles,
         'grips': e.grips,
         'force': e.force,
         'mechanic': e.mechanic,
      };
   }

   /// 🔹 GLOBAL LOGOUT FUNCTION
   static Future<void> logout() async {
      // 1. Clear Memory Variables
      userId = "";
      email = "";
      role = "";
      userName = "";
      isApproved.value = false;

      // 2. Clear Local Storage (Session only; keeps remembered email, theme, cache)
      await sharedPreferencesHelper.clearSessionData();

      // 3. Sign Out from Firebase
      await FirebaseAuth.instance.signOut();

      // 4. Navigate to Login
      Get.offAllNamed(LoginScreen.pageId);
   }

}