import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant.dart';

//
// class MuscleWikiController extends GetxController {
//   final String apiKey = "8ed3afccfamsh526fb91fb118089p110fbbjsnaada4f16a265";
//   final String baseUrl = "https://musclewiki-api.p.rapidapi.com";
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // State
//   var isLoading = true.obs;
//   var exercises = <Exercise>[].obs;
//   var visibleExercises = <Exercise>[].obs;
//   var isLoadingFromCache = false.obs;
//
//   // Filters
//   var categoryList = <CategoryItem>[].obs;
//   var genderList = <String>["Both", "Male", "Female"].obs;
//   var difficultyList = <String>["All Levels", "Beginner", "Novice", "Intermediate", "Advanced"].obs;
//
//   // Selected Values
//   var selectedCategory = Rx<CategoryItem>(CategoryItem(name: "all", displayName: "All Categories"));
//   var selectedGender = "Both".obs;
//   var selectedDifficulty = "All Levels".obs;
//
//   var isSearching = false.obs;
//   ScrollController scrollController = ScrollController();
//   int currentOffset = 0;
//   final int limit = 50;
//   var hasMore = true.obs;
//
//   // Visibility
//   var hiddenExerciseIds = <String>[].obs;
//   Map<String, Map<String, dynamic>> visibilityRules = {};
//
//   @override
//   void onInit() {
//     super.onInit();
//     categoryList.add(selectedCategory.value);
//
//     _initializeData();
//     _listenToVisibilityChanges();
//
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
//         if (!isLoading.value && hasMore.value && !isSearching.value) {
//           fetchExercises(loadMore: true);
//         }
//       }
//     });
//   }
//
//   Future<void> _initializeData() async {
//     isLoadingFromCache.value = true;
//     bool cacheValid = await AppConstants.isCacheValid();
//
//     if (cacheValid) {
//       print("📦 Loading from cache...");
//
//       List<CategoryItem>? cachedCategories = await AppConstants.getCachedCategories();
//       if (cachedCategories != null && cachedCategories.isNotEmpty) {
//         categoryList.assignAll([
//           CategoryItem(name: "all", displayName: "All Categories"),
//           ...cachedCategories
//         ]);
//         if (categoryList.isNotEmpty) selectedCategory.value = categoryList.first;
//       }
//
//       List<Exercise>? cachedExercises = await AppConstants.getCachedExercises();
//       if (cachedExercises != null && cachedExercises.isNotEmpty) {
//         exercises.assignAll(cachedExercises);
//         _applyVisibilityFilter();
//         isLoading.value = false;
//         isLoadingFromCache.value = false;
//         return;
//       }
//     }
//
//     print("🌐 Cache invalid or empty, fetching fresh data...");
//     isLoadingFromCache.value = false;
//     await fetchFilters();
//     await fetchExercises(reset: true);
//   }
//
//   Future<void> fetchFilters() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/categories'),
//         headers: {
//           'X-RapidAPI-Key': apiKey,
//           'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'
//         },
//       );
//
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         List<CategoryItem> loadedCats = data.map((item) {
//           String apiName = item['name'] ?? "";
//           String uiName = item['display_name'] ?? apiName;
//           int count = item['count'] ?? 0;
//           if (uiName.isEmpty) uiName = apiName;
//           if (uiName.isNotEmpty) uiName = uiName[0].toUpperCase() + uiName.substring(1);
//           return CategoryItem(name: apiName, displayName: "$uiName ($count)");
//         }).toList();
//
//         loadedCats.sort((a, b) => a.displayName.compareTo(b.displayName));
//         categoryList.assignAll([
//           CategoryItem(name: "all", displayName: "All Categories"),
//           ...loadedCats
//         ]);
//         if (categoryList.isNotEmpty) selectedCategory.value = categoryList.first;
//
//         await AppConstants.cacheCategories(loadedCats);
//       }
//     } catch (e) {
//       print("Filter Error: $e");
//     }
//   }
//
//   Future<void> fetchExercises({bool loadMore = false, bool reset = false}) async {
//     if (isLoading.value && !reset) return;
//     if (loadMore && !hasMore.value) return;
//
//     if (reset) {
//       isLoading.value = true;
//       exercises.clear();
//       visibleExercises.clear();
//       currentOffset = 0;
//       hasMore.value = true;
//       isSearching.value = false;
//     } else {
//       isLoading.value = true;
//     }
//
//     try {
//       final uri = Uri.parse('$baseUrl/exercises');
//       Map<String, String> queryParams = {
//         'limit': '$limit',
//         'offset': '$currentOffset',
//       };
//
//       if (selectedCategory.value.name != "all") {
//         queryParams['category'] = selectedCategory.value.name;
//       }
//
//       if (selectedDifficulty.value != "All Levels") {
//         queryParams['difficulty'] = selectedDifficulty.value.toLowerCase();
//       }
//
//       if (selectedGender.value != "Both") {
//         queryParams['gender'] = selectedGender.value.toLowerCase();
//       }
//
//       final urlWithParams = uri.replace(queryParameters: queryParams);
//       print("🚀 Requesting: $urlWithParams");
//
//       await _makeApiCall(urlWithParams);
//
//       if (reset && exercises.isNotEmpty) {
//         await AppConstants.cacheExercises(exercises);
//         _batchFetchExerciseDetails(exercises);
//       }
//     } catch (e) {
//       print("Fetch Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _batchFetchExerciseDetails(List<Exercise> exerciseList) async {
//     print("🔄 Starting batch fetch for ${exerciseList.length} exercises...");
//     int successCount = 0;
//
//     for (var exercise in exerciseList) {
//       var cached = await AppConstants.getCachedExerciseDetail(exercise.id);
//       if (cached != null) continue;
//
//       try {
//         final uri = Uri.parse('$baseUrl/exercises/${exercise.id}');
//         final urlWithParams = (selectedGender.value != "Both")
//             ? uri.replace(queryParameters: {'gender': selectedGender.value.toLowerCase()})
//             : uri;
//
//         final response = await http.get(
//           urlWithParams,
//           headers: {
//             'X-RapidAPI-Key': apiKey,
//             'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'
//           },
//         );
//
//         if (response.statusCode == 200) {
//           final json = jsonDecode(response.body);
//           await AppConstants.cacheExerciseDetail(exercise.id, json);
//           successCount++;
//         } else if (response.statusCode == 429) {
//           break;
//         }
//
//         await Future.delayed(const Duration(milliseconds: 100));
//       } catch (e) {
//         print("❌ Error fetching ${exercise.name}: $e");
//       }
//     }
//
//     print("🎉 Batch fetch complete! Success: $successCount");
//   }
//
//   Future<void> _makeApiCall(Uri uri) async {
//     try {
//       final response = await http.get(uri, headers: {
//         'X-RapidAPI-Key': apiKey,
//         'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com',
//       });
//
//       print("📥 Status Code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final dynamic decodedData = json.decode(response.body);
//         List<dynamic> newDataList = [];
//
//         if (decodedData is Map && decodedData.containsKey('results')) {
//           newDataList = decodedData['results'];
//         } else if (decodedData is List) {
//           newDataList = decodedData;
//         }
//
//         print("📦 Items Received: ${newDataList.length}");
//
//         if (newDataList.isEmpty) {
//           hasMore.value = false;
//         } else {
//           var newExercises = newDataList.map((json) => Exercise.fromJson(json)).toList();
//           exercises.addAll(newExercises);
//           _applyVisibilityFilter();
//
//           if (!isSearching.value) currentOffset += limit;
//         }
//       } else if (response.statusCode == 429) {
//         print("❌ RATE LIMIT EXCEEDED");
//         hasMore.value = false;
//       }
//     } catch (e) {
//       print("Network Error: $e");
//     }
//   }
//
//   void clearFilters() {
//     if (categoryList.isNotEmpty) selectedCategory.value = categoryList.first;
//     selectedGender.value = "Both";
//     selectedDifficulty.value = "All Levels";
//     fetchExercises(reset: true);
//   }
//
//   Future<void> searchExercises(String query) async {
//     if (query.isEmpty) return;
//     isLoading.value = true;
//     exercises.clear();
//     visibleExercises.clear();
//     isSearching.value = true;
//     try {
//       final uri = Uri.parse('$baseUrl/search');
//       await _makeApiCall(uri.replace(queryParameters: {'q': query, 'limit': '20'}));
//     } catch (e) {
//       print("Search Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ==============================================================================
//   // ✅ LISTEN TO VISIBILITY CHANGES
//   // ==============================================================================
//   void _listenToVisibilityChanges() {
//     _db.collection('exercise_visibility').snapshots().listen((snapshot) {
//       print("🔄 Visibility rules updated (${snapshot.docs.length} rules)");
//       hiddenExerciseIds.clear();
//       visibilityRules.clear();
//
//       for (var doc in snapshot.docs) {
//         var data = doc.data();
//         visibilityRules[doc.id] = data;
//
//         bool isVisibleToAll = data['isVisibleToAll'] ?? true;
//         List visibleForUsers = data['visibleForUsers'] ?? [];
//
//         if (!isVisibleToAll && visibleForUsers.isEmpty) {
//           hiddenExerciseIds.add(doc.id);
//         }
//
//         print("   Exercise ${doc.id}: isVisibleToAll=$isVisibleToAll, visibleForUsers=$visibleForUsers");
//       }
//
//       _applyVisibilityFilter();
//     });
//   }
//
//   // ==============================================================================
//   // ✅ NEW LOGIC: DEFAULT HIDE ALL FOR STUDENTS
//   // ==============================================================================
//   void _applyVisibilityFilter() {
//     String currentRole = AppConstants.role;
//     String myUid = _auth.currentUser?.uid ?? "";
//
//     print("🔍 Applying visibility filter:");
//     print("   Current role: $currentRole");
//     print("   Current UID: $myUid");
//     print("   Total exercises: ${exercises.length}");
//     print("   Visibility rules count: ${visibilityRules.length}");
//
//     if (currentRole == 'trainer' || currentRole == 'admin') {
//       // Trainers/Admins see ALL exercises
//       visibleExercises.assignAll(exercises);
//       print("   ✅ Trainer/Admin: Showing all ${exercises.length} exercises");
//     } else {
//       // ==============================================================
//       // STUDENTS: DEFAULT HIDE ALL
//       // Only show if explicitly in visibleForUsers array
//       // ==============================================================
//       List<Exercise> filtered = exercises.where((ex) {
//         String exId = ex.id.toString();
//
//         // Check if there's a visibility rule for this exercise
//         if (!visibilityRules.containsKey(exId)) {
//           // ❌ NO RULE = HIDDEN (This is the key change!)
//           print("   ❌ ${ex.name} ($exId): No rule = HIDDEN from students");
//           return false;
//         }
//
//         var rule = visibilityRules[exId]!;
//         bool isVisibleToAll = rule['isVisibleToAll'] ?? false; // Default false for safety
//         List visibleForUsers = List.from(rule['visibleForUsers'] ?? []);
//
//         if (isVisibleToAll) {
//           // Exercise is globally visible
//           print("   ✅ ${ex.name} ($exId): Globally visible");
//           return true;
//         } else {
//           // Check if student is in allowed list
//           bool canSee = visibleForUsers.contains(myUid);
//
//           if (canSee) {
//             print("   ✅ ${ex.name} ($exId): Student IS in allowed list");
//           } else {
//             print("   ❌ ${ex.name} ($exId): Student NOT in allowed list");
//           }
//
//           return canSee;
//         }
//       }).toList();
//
//       visibleExercises.assignAll(filtered);
//       print("   📊 Student: Showing ${filtered.length}/${exercises.length} exercises");
//
//       if (filtered.isEmpty && exercises.isNotEmpty) {
//         print("   ⚠️ WARNING: Student sees 0 exercises! Trainer needs to assign exercises.");
//       }
//     }
//   }
//
//   // ==============================================================================
//   // Check if exercise is hidden (for UI display)
//   // ==============================================================================
//   bool isHiddenReversed(int id) {
//     String exId = id.toString();
//
//     if (!visibilityRules.containsKey(exId)) {
//       // ✅ NO DOCUMENT = HIDDEN BY DEFAULT
//       return true;
//     }
//
//     var rule = visibilityRules[exId]!;
//     bool isVisibleToAll = rule['isVisibleToAll'] ?? false;
//
//     // ✅ If isVisibleToAll = false, it's hidden (restricted)
//     // ✅ If isVisibleToAll = true, it's NOT hidden (visible to all)
//     return !isVisibleToAll;
//   }
//
//   // ==============================================================================
//   // Toggle exercise visibility (for trainers)
//   // ==============================================================================
//   Future<void> toggleExerciseVisibility(Exercise ex) async {
//     String exId = ex.id.toString();
//     var docRef = _db.collection('exercise_visibility').doc(exId);
//     bool currentlyHidden = isHiddenReversed(ex.id);
//
//     print("🔄 Toggling exercise: ${ex.name}");
//     print("   Currently hidden: $currentlyHidden");
//
//     if (currentlyHidden) {
//       // Currently hidden → Make visible to ALL students
//       await docRef.set({
//         'exerciseId': exId,
//         'exerciseName': ex.name,
//         'isVisibleToAll': true, // ✅ Set to TRUE
//         'visibleForUsers': [], // Clear the list
//         'controlledBy': _auth.currentUser?.uid,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       print("   ✅ Now visible to ALL students");
//       Get.snackbar(
//         "Visible to All",
//         "${ex.name} is now visible to all students",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         icon: const Icon(Icons.visibility, color: Colors.white),
//         duration: const Duration(seconds: 2),
//       );
//     } else {
//       // Currently visible → Hide from ALL students
//       await docRef.set({
//         'exerciseId': exId,
//         'exerciseName': ex.name,
//         'isVisibleToAll': false, // ✅ Set to FALSE
//         'visibleForUsers': [], // Empty = no one can see it
//         'controlledBy': _auth.currentUser?.uid,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       print("   ✅ Now hidden from ALL students");
//       Get.snackbar(
//         "Hidden from All",
//         "${ex.name} is hidden from all students",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         icon: const Icon(Icons.visibility_off, color: Colors.white),
//         duration: const Duration(seconds: 2),
//       );
//     }
//   }
//
//   Future<void> forceRefresh() async {
//     await AppConstants.clearMuscleWikiCache();
//     await fetchFilters();
//     await fetchExercises(reset: true);
//   }
// }

// ==========================================
// IMPROVED MUSCLE WIKI CONTROLLER
// ✅ PERMANENT CACHE - Only Manual Refresh
// ==========================================

class MuscleWikiController extends GetxController {
  //final String apiKey = "d88915ae1bmshf18caa55ee676a7p174beejsnd91075612964";
  //final String apiKey = "cfcd64bc86mshd6b3aa16e73fb48p1cffa5jsn933693c31340";
  //final String baseUrl = "https://musclewiki-api.p.rapidapi.com";

  final String baseUrl = "https://stripe-backend-sigma.vercel.app/api/musclewiki";

  Map<String, String> _defaultHeaders() {
    // Some backends/middleware behave differently when Accept/User-Agent are missing.
    return const {
      'Accept': 'application/json',
    };
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State
  var isLoading = true.obs;
  var exercises = <Exercise>[].obs;
  var visibleExercises = <Exercise>[].obs;
  var isLoadingFromCache = false.obs;
  var hasRateLimitError = false.obs; // ✅ NEW: Track rate limit state
  var hasAuthError = false.obs; // ✅ NEW: Track auth/permission errors (401/403)
  var apiDisabled = true.obs; // ✅ TEMP: Disable all API calls (use only manual + cache)
  var lastSuccessfulFetch = Rx<DateTime?>(null); // ✅ NEW: Track last successful API call

  // Filters
  var categoryList = <CategoryItem>[].obs;
  var genderList = <String>["Both", "Male", "Female"].obs;
  var difficultyList = <String>["All Levels", "Beginner", "Novice", "Intermediate", "Advanced"].obs;

  // Selected Values
  var selectedCategory = Rx<CategoryItem>(CategoryItem(name: "all", displayName: "All Categories"));
  var selectedGender = "Both".obs;
  var selectedDifficulty = "All Levels".obs;
// ✅ Separate Lists to hold data
  List<Exercise> _manualExercises = [];
  List<Exercise> _apiExercises = [];
  var isSearching = false.obs;
  ScrollController scrollController = ScrollController();
  int currentOffset = 0;
  final int limit = 50;
  var hasMore = true.obs;

  // Visibility
  var hiddenExerciseIds = <String>[].obs;
  Map<String, Map<String, dynamic>> visibilityRules = {};

  @override
  void onInit() {
    super.onInit();
    categoryList.add(selectedCategory.value);

    _initializeData();
    _listenToVisibilityChanges();
    _loadLastFetchTime(); // ✅ NEW: Load last successful fetch time

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading.value && hasMore.value && !isSearching.value) {
          if (!apiDisabled.value) {
            fetchExercises(loadMore: true);
          }
        }
      }
    });
  }

  // ==========================================
  // ✅ NEW: Load Last Successful Fetch Time
  // ==========================================
  Future<void> _loadLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('last_api_fetch_time');
      if (timeStr != null) {
        lastSuccessfulFetch.value = DateTime.parse(timeStr);
        print('📅 Last successful API fetch: ${lastSuccessfulFetch.value}');
      }
    } catch (e) {
      print('❌ Error loading last fetch time: $e');
    }
  }

  // ==========================================
  // ✅ PERMANENT CACHE: Initialize from cache first; API only when cache empty or manual refresh
  // ==========================================

  Future<void> _initializeData() async {
    isLoading.value = true;
    isLoadingFromCache.value = true;

    print("📦 Initializing Data (cache-first)...");

    // 1. STRICT: Check cache first. If we have data, use it and STOP (no API).
    List<Exercise>? cachedExercises = await AppConstants.getCachedExercises();

    if (cachedExercises != null && cachedExercises.isNotEmpty) {
      print('✅ Loaded ${cachedExercises.length} exercises from cache — no API call');
      _apiExercises = List.from(cachedExercises);
      isLoadingFromCache.value = false;
      hasMore.value = false;

      List<CategoryItem>? cachedCats = await AppConstants.getCachedCategories();
      if (cachedCats != null && cachedCats.isNotEmpty) {
        categoryList.assignAll([
          CategoryItem(name: "all", displayName: "All Categories"),
          ...cachedCats,
        ]);
        if (categoryList.isNotEmpty && selectedCategory.value.name == "all") {
          selectedCategory.value = categoryList.first;
        }
      }

      // 2. Load manual exercises (Firestore) and merge with cached API data
      await fetchManualExercises();
      _mergeAndApplyFilters();

      isLoading.value = false;
      _applyVisibilityFilter();
      return;
    }

    // 3. Cache is empty:
    // If API is disabled, load only manual exercises and continue.
    // This prevents "blank" screens on fresh installs when API is unavailable.
    isLoadingFromCache.value = false;
    hasMore.value = false;
    if (apiDisabled.value) {
      print("⚠️ API disabled (temporary). Loading manual exercises only...");
      await fetchManualExercises();
      isLoading.value = false;
      return;
    }

    // Otherwise, fetch from API
    print("🌐 Cache empty, fetching from API...");
    await fetchFilters();
    if (hasAuthError.value) {
      await fetchManualExercises();
      isLoading.value = false;
      return;
    }
    await fetchExercises(reset: true);
  }

  /// Merges _manualExercises + filtered _apiExercises and assigns to [exercises]. No API call.
  void _mergeAndApplyFilters() {
    List<Exercise> filteredApi = _getFilteredApiExercises();
    exercises.assignAll([..._manualExercises, ...filteredApi]);
  }

  /// Returns _apiExercises filtered by current selected category/difficulty (local only).
  List<Exercise> _getFilteredApiExercises() {
    final cat = selectedCategory.value;
    final diff = selectedDifficulty.value;
    return _apiExercises.where((e) {
      final catMatch = cat.name == "all" || (e.category.toLowerCase() == cat.name.toLowerCase());
      final diffMatch = diff == "All Levels" || (e.difficulty.toLowerCase() == diff.toLowerCase());
      return catMatch && diffMatch;
    }).toList();
  }

  /// Fetch manual exercises from Firestore and merge with _apiExercises (no API call).
  Future<void> fetchManualExercises() async {
    try {
      print("📦 Fetching manual exercises from Firestore...");
      var snapshot = await _db.collection('exercises')
          .orderBy('createdAt', descending: true)
          .get();

      _manualExercises = snapshot.docs
          .map((doc) => Exercise.fromFirestore(doc.data(), doc.id))
          .toList();

      print("✅ Found ${_manualExercises.length} manual exercises");
      _mergeAndApplyFilters();
      _applyVisibilityFilter();
    } catch (e) {
      print("❌ Error fetching manual exercises: $e");
    }
  }


  Future<void> fetchFilters() async {
    if (apiDisabled.value) return;
    try {
      // final response = await http.get(
      //   Uri.parse('$baseUrl/categories'),
      //   headers: {
      //     'X-RapidAPI-Key': apiKey,
      //     'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'
      //   },
      // );

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'endpoint': 'categories',
      });

      final response = await http.get(uri, headers: _defaultHeaders());

      if (response.statusCode == 200) {
        hasAuthError.value = false;
        List<dynamic> data = json.decode(response.body);
        List<CategoryItem> loadedCats = data.map((item) {
          String apiName = item['name'] ?? "";
          String uiName = item['display_name'] ?? apiName;
          int count = item['count'] ?? 0;
          if (uiName.isEmpty) uiName = apiName;
          if (uiName.isNotEmpty) uiName = uiName[0].toUpperCase() + uiName.substring(1);
          return CategoryItem(name: apiName, displayName: "$uiName ($count)");
        }).toList();

        loadedCats.sort((a, b) => a.displayName.compareTo(b.displayName));
        categoryList.assignAll([
          CategoryItem(name: "all", displayName: "All Categories"),
          ...loadedCats
        ]);
        if (categoryList.isNotEmpty) selectedCategory.value = categoryList.first;

        await AppConstants.cacheCategories(loadedCats);
        print('✅ Categories fetched and cached');

      } else if (response.statusCode == 429) {
        print('❌ RATE LIMIT: Categories fetch failed');
        hasRateLimitError.value = true;
        _showOfflineCachedSnackbar();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ AUTH ERROR (${response.statusCode}) on categories: ${response.body}');
        hasAuthError.value = true;
        hasMore.value = false;
        _showOfflineCachedSnackbar();
      }
    } catch (e) {
      print("❌ Filter Error: $e");
    }
  }

  // ==========================================
  // ✅ IMPROVED: Fetch Exercises (with rate limit handling)
  // ==========================================
  Future<void> fetchExercises({bool loadMore = false, bool reset = false}) async {
    if (apiDisabled.value) {
      hasMore.value = false;
      isLoading.value = false;
      _mergeAndApplyFilters();
      _applyVisibilityFilter();
      return;
    }
    if (isLoading.value && !reset) return;
    if (loadMore && !hasMore.value) return;
    if (hasRateLimitError.value && !reset) return;
    if (hasAuthError.value && !reset) return;

    if (reset) {
      isLoading.value = true;
      exercises.clear();
      visibleExercises.clear();
      _apiExercises.clear();
      currentOffset = 0;
      hasMore.value = true;
      isSearching.value = false;
      hasRateLimitError.value = false;
      hasAuthError.value = false;
      await fetchManualExercises();
    } else {
      isLoading.value = true;
    }

    try {
      final uri = Uri.parse('$baseUrl');
      Map<String, String> queryParams = {
        'endpoint': 'exercises',
        'limit': '$limit',
        'offset': '$currentOffset',
      };

      if (selectedCategory.value.name != "all") {
        queryParams['category'] = selectedCategory.value.name;
      }

      if (selectedDifficulty.value != "All Levels") {
        queryParams['difficulty'] = selectedDifficulty.value.toLowerCase();
      }

      if (selectedGender.value != "Both") {
        queryParams['gender'] = selectedGender.value.toLowerCase();
      }

      final urlWithParams = uri.replace(queryParameters: queryParams);
      print("🚀 Requesting: $urlWithParams");

      await _makeApiCall(urlWithParams);

      if (reset && _apiExercises.isNotEmpty && !hasRateLimitError.value) {
        await AppConstants.cacheExercises(_apiExercises);
        await _saveLastFetchTime();
        _batchFetchExerciseDetails(_apiExercises);
        print('✅ Exercises cached permanently');
      }
    } catch (e) {
      print("❌ Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // ✅ NEW: Save Last Successful Fetch Time
  // ==========================================
  Future<void> _saveLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString('last_api_fetch_time', now.toIso8601String());
      lastSuccessfulFetch.value = now;
      print('✅ Saved last fetch time: $now');
    } catch (e) {
      print('❌ Error saving fetch time: $e');
    }
  }

  // ==========================================
  // ✅ IMPROVED: API Call with Rate Limit Detection
  // ==========================================
  Future<void> _makeApiCall(Uri uri) async {
    if (apiDisabled.value) return;
    try {
      final response = await http.get(uri, headers: _defaultHeaders());

      print("📥 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        hasRateLimitError.value = false; // ✅ Clear error flag on success
        hasAuthError.value = false;

        final dynamic decodedData = json.decode(response.body);
        List<dynamic> newDataList = [];

        if (decodedData is Map && decodedData.containsKey('results')) {
          newDataList = decodedData['results'];
        } else if (decodedData is List) {
          newDataList = decodedData;
        }

        print("📦 Items Received: ${newDataList.length}");

        if (newDataList.isEmpty) {
          hasMore.value = false;
        }
        else {
          var newExercises = newDataList.map((json) => Exercise.fromJson(json)).toList();
          _apiExercises.addAll(newExercises);


          if (!isSearching.value) currentOffset += limit;
        }
        //exercises.addAll(newExercises);
        // ✅ CRITICAL MERGE: Manual First + API Second
        exercises.assignAll([..._manualExercises, ..._apiExercises]);
        _applyVisibilityFilter();
      }
      else if (response.statusCode == 429) {
        print("❌ RATE LIMIT (429) — switching to offline/cached mode");
        hasRateLimitError.value = true;
        exercises.assignAll([..._manualExercises, ..._apiExercises]);
        _applyVisibilityFilter();
        _showOfflineCachedSnackbar();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print("❌ AUTH ERROR (${response.statusCode}) — ${response.body}");
        hasAuthError.value = true;
        hasMore.value = false;
        exercises.assignAll([..._manualExercises, ..._apiExercises]);
        _applyVisibilityFilter();
        _showOfflineCachedSnackbar();
      } else {
        print("❌ API ERROR (${response.statusCode}) — ${response.body}");
      }
    } catch (e) {
      print("❌ Network Error: $e");
    }
  }



  void _showOfflineCachedSnackbar() {
    Get.snackbar(
      'Offline / Cached mode',
      hasAuthError.value
          ? 'API auth failed (401/403). You are viewing cached/manual data only.'
          : 'API limit reached. You are viewing cached data only.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.cloud_off, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==========================================
  // ✅ Manual refresh: API is ONLY called here (pull-to-refresh). Never on init if cache exists.
  // ==========================================
  Future<void> forceRefreshFromAPI() async {
    if (apiDisabled.value) {
      Get.snackbar(
        'Offline / Manual mode',
        'API calls are disabled. Showing cached/manual data only.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.cloud_off, color: Colors.white),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (hasRateLimitError.value) {
      _showOfflineCachedSnackbar();
      return;
    }
    print('🔄 Force refresh from API (pull-to-refresh)');
    await fetchFilters();
    await fetchExercises(reset: true);
  }

  /// Pull-to-refresh entry point: delegates to forceRefreshFromAPI.
  Future<void> refresh() async {
    await forceRefreshFromAPI();
  }

  // ==========================================
  // Existing methods
  // ==========================================

  Future<void> _batchFetchExerciseDetails(List<Exercise> exerciseList) async {
    if (apiDisabled.value) return;
    print("🔄 Batch fetch details for ${exerciseList.length} exercises (skipping cached)...");
    int successCount = 0;
    int skippedCached = 0;

    for (var exercise in exerciseList) {
      if (hasRateLimitError.value) break;

      // Skip manual exercises (String id); only API exercises have numeric id
      if (exercise.id is String) continue;

      var cached = await AppConstants.getCachedExerciseDetail(exercise.id);
      if (cached != null) {
        skippedCached++;
        continue;
      }

      try {
        final uri = Uri.parse(baseUrl);
        Map<String, String> queryParams = {
          'endpoint': 'exercises/${exercise.id}',
        };
        if (selectedGender.value != "Both") {
          queryParams['gender'] = selectedGender.value.toLowerCase();
        }

        final response = await http.get(uri.replace(queryParameters: queryParams));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          await AppConstants.cacheExerciseDetail(exercise.id, json);
          successCount++;
        } else if (response.statusCode == 429) {
          print('❌ Rate limit (429) in batch — stopping all pending calls');
          hasRateLimitError.value = true;
          _showOfflineCachedSnackbar();
          break;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print("❌ Error fetching ${exercise.name}: $e");
      }
    }

    print("🎉 Batch details: $successCount fetched, $skippedCached from cache");
  }

  void clearFilters() {
    if (categoryList.isNotEmpty) selectedCategory.value = categoryList.first;
    selectedGender.value = "Both";
    selectedDifficulty.value = "All Levels";
    applyFiltersLocally();
  }

  /// Apply current category/difficulty/gender filter to existing data only (no API).
  void applyFiltersLocally() {
    _mergeAndApplyFilters();
    _applyVisibilityFilter();
  }

  Future<void> searchExercises(String query) async {
    if (query.isEmpty) return;
    isLoading.value = true;
    exercises.clear();
    visibleExercises.clear();
    isSearching.value = true;
    try {
      // final uri = Uri.parse('$baseUrl/search');
      // await _makeApiCall(uri.replace(queryParameters: {'q': query, 'limit': '20'}));

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'endpoint': 'search',
        'q': query,
        'limit': '20'
      });

      await _makeApiCall(uri);
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

    void _listenToVisibilityChanges() {
    _db.collection('exercise_visibility').snapshots().listen((snapshot) {
      visibilityRules.clear(); // Clear old rules

      for (var doc in snapshot.docs) {
        visibilityRules[doc.id] = doc.data();
      }

      // Re-apply filter whenever rules change (e.g. User buys a plan)
      _applyVisibilityFilter();
    });
  }

  void _applyVisibilityFilter() {
    String currentRole = AppConstants.role; // 'user', 'trainer', or 'admin'
    String myUid = _auth.currentUser?.uid ?? "";

    print("🔍 Applying visibility filter:");
    print("   Current role: $currentRole");
    print("   Total exercises loaded: ${exercises.length}");

    // ✅ FIX 1: ADMINS & TRAINERS ALWAYS SEE EVERYTHING
    if (currentRole == 'trainer' || currentRole == 'admin') {
      visibleExercises.assignAll(exercises);
      print("   ✅ Admin/Trainer Mode: Showing all ${exercises.length} exercises.");
      return;
    }

    // 2. USERS (STUDENTS): Filtering Logic
    List<Exercise> filtered = exercises.where((ex) {
      String exId = ex.id.toString();

      // ✅ Always show manual exercises (Firestore) to users.
      // Manual exercises have String doc IDs; API exercises have numeric IDs.
      if (ex.id is String) return true;

      // ✅ FIX 2: Handle cases where NO rule exists in 'exercise_visibility'
      // If the exercise is NOT in the visibility collection, we need a default behavior.
      // Option A: Hide it (Strict) -> Keep 'return false'
      // Option B: Show it (Open)   -> Change to 'return true'
      // Currently, it's set to Strict (False).

      if (!visibilityRules.containsKey(exId)) {
        // ⚠️ CRITICAL: If you added exercises manually but didn't set visibility rules yet,
        // they will be HIDDEN here.
        // For debugging, let's print which ones are missing rules.
        // print("   ❌ Hidden (No Rule): ${ex.name}");
        return false;
      }

      var rule = visibilityRules[exId]!;
      bool isVisibleToAll = rule['isVisibleToAll'] ?? false;
      List visibleForUsers = List.from(rule['visibleForUsers'] ?? []);

      // Rule 1: Is it visible to everyone?
      if (isVisibleToAll) return true;

      // Rule 2: Is it assigned specifically to ME?
      return visibleForUsers.contains(myUid);

    }).toList();

    visibleExercises.assignAll(filtered);
    print("   🔒 User View: Showing ${filtered.length} / ${exercises.length} exercises.");
  }

  bool isHiddenReversed(dynamic id) {
    String exId = id.toString();

    if (!visibilityRules.containsKey(exId)) {
      // Manual exercises (String IDs) are visible by default.
      if (id is String) return false;
      return true;
    }

    var rule = visibilityRules[exId]!;
    bool isVisibleToAll = rule['isVisibleToAll'] ?? false;

    return !isVisibleToAll;
  }

  Future<void> toggleExerciseVisibility(Exercise ex) async {
    String exId = ex.id.toString();
    var docRef = _db.collection('exercise_visibility').doc(exId);
    bool currentlyHidden = isHiddenReversed(ex.id);

    print("🔄 Toggling exercise: ${ex.name}");
    print("   Currently hidden: $currentlyHidden");

    if (currentlyHidden) {
      await docRef.set({
        'exerciseId': exId,
        'exerciseName': ex.name,
        'isVisibleToAll': true,
        'visibleForUsers': [],
        'controlledBy': _auth.currentUser?.uid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("   ✅ Now visible to ALL students");
      Get.snackbar(
        "Visible to All",
        "${ex.name} is now visible to all students",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.visibility, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } else {
      await docRef.set({
        'exerciseId': exId,
        'exerciseName': ex.name,
        'isVisibleToAll': false,
        'visibleForUsers': [],
        'controlledBy': _auth.currentUser?.uid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("   ✅ Now hidden from ALL students");
      Get.snackbar(
        "Hidden from All",
        "${ex.name} is hidden from all students",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.visibility_off, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> forceRefresh() async {
    await AppConstants.clearMuscleWikiCache();
    await fetchFilters();
    await fetchExercises(reset: true);
  }
}

// ==========================================
// ✅ NEW: Rate Limit Status Banner
// ==========================================

class RateLimitBanner extends StatelessWidget {
  const RateLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MuscleWikiController>();

    return Obx(() {
      if (!controller.hasRateLimitError.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Using Cached Exercises',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'API limit reached. All cached data is still available.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CategoryItem {
  final String name;
  final String displayName;
  CategoryItem({required this.name, required this.displayName});
}

// ==============================================================================
// 3. EXERCISE MODEL
// ==============================================================================
// ==============================================================================
// UPDATED Exercise Model with SMART IMAGE MATCHING
// ==============================================================================
class Exercise {
  final dynamic id;
  final String name;
  final String category;
  final String difficulty;
  final String? description;
  final List<String> steps;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> targetMuscles;
  final List<String> grips;
  final String? force;
  final String? mechanic;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.steps,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.targetMuscles = const [],
    this.grips = const [],
    this.force,
    this.mechanic,
  });

  // 🎯 SMART IMAGE MATCHER - Returns image based on exercise name
  String getCategoryImage() {
    String n = name.toLowerCase().trim();

    // ===========================================================
    // EXACT EXERCISE NAME MATCHING (Most Specific)
    // ===========================================================

    // --- CHEST EXERCISES ---
    if (n.contains("bench press")) {
      if (n.contains("incline")) {
        return "https://images.pexels.com/photos/4164849/pexels-photo-4164849.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("decline")) {
        return "https://images.pexels.com/photos/3837781/pexels-photo-3837781.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/3837781/pexels-photo-3837781.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("chest press") || n.contains("pec deck")) {
      return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("push up") || n.contains("pushup") || n.contains("push-up")) {
      return "https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("chest fly") || n.contains("cable fly") || n.contains("dumbbell fly")) {
      return "https://images.pexels.com/photos/4162487/pexels-photo-4162487.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- LEG EXERCISES ---
    if (n.contains("squat")) {
      if (n.contains("front")) {
        return "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("goblet")) {
        return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/136404/pexels-photo-136404.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("leg press")) {
      return "https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("lunge")) {
      return "https://images.pexels.com/photos/3757954/pexels-photo-3757954.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("leg curl") || n.contains("hamstring curl")) {
      return "https://images.pexels.com/photos/6388373/pexels-photo-6388373.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("leg extension")) {
      return "https://images.pexels.com/photos/791763/pexels-photo-791763.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("calf raise")) {
      return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- BACK EXERCISES ---
    if (n.contains("deadlift")) {
      if (n.contains("romanian") || n.contains("rdl")) {
        return "https://images.pexels.com/photos/703016/pexels-photo-703016.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("sumo")) {
        return "https://images.pexels.com/photos/2261477/pexels-photo-2261477.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("pull up") || n.contains("chin up") || n.contains("pullup")) {
      return "https://images.pexels.com/photos/4164765/pexels-photo-4164765.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("lat pulldown") || n.contains("pulldown")) {
      return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("row")) {
      if (n.contains("barbell")) {
        return "https://images.pexels.com/photos/949132/pexels-photo-949132.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("dumbbell")) {
        return "https://images.pexels.com/photos/3912944/pexels-photo-3912944.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("cable") || n.contains("seated")) {
        return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/949132/pexels-photo-949132.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- SHOULDER EXERCISES ---
    if (n.contains("shoulder press") || n.contains("overhead press") || n.contains("military press")) {
      if (n.contains("dumbbell")) {
        return "https://images.pexels.com/photos/6550851/pexels-photo-6550851.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/1431282/pexels-photo-1431282.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("lateral raise") || n.contains("side raise")) {
      return "https://images.pexels.com/photos/6550851/pexels-photo-6550851.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("front raise")) {
      return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("rear delt") || n.contains("reverse fly") || n.contains("face pull")) {
      return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("shrug")) {
      return "https://images.pexels.com/photos/1092878/pexels-photo-1092878.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- ARM EXERCISES (BICEPS) ---
    if (n.contains("bicep curl") || n.contains("curl")) {
      if (n.contains("hammer")) {
        return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("dumbbell")) {
        return "https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("barbell") || n.contains("ez bar")) {
        return "https://images.pexels.com/photos/1552249/pexels-photo-1552249.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("cable")) {
        return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("preacher")) {
        return "https://images.pexels.com/photos/4162487/pexels-photo-4162487.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- ARM EXERCISES (TRICEPS) ---
    if (n.contains("tricep")) {
      if (n.contains("pushdown") || n.contains("press down")) {
        return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("overhead") || n.contains("extension")) {
        return "https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      if (n.contains("kickback")) {
        return "https://images.pexels.com/photos/3912944/pexels-photo-3912944.jpeg?auto=compress&cs=tinysrgb&w=600";
      }
      return "https://images.pexels.com/photos/5327502/pexels-photo-5327502.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("skull crusher") || n.contains("lying tricep")) {
      return "https://images.pexels.com/photos/5327502/pexels-photo-5327502.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("dip")) {
      return "https://images.pexels.com/photos/4164849/pexels-photo-4164849.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- ABS/CORE EXERCISES ---
    if (n.contains("plank")) {
      return "https://images.pexels.com/photos/4162452/pexels-photo-4162452.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("crunch") || n.contains("sit up") || n.contains("situp")) {
      return "https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("russian twist")) {
      return "https://images.pexels.com/photos/4498574/pexels-photo-4498574.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("leg raise") || n.contains("hanging")) {
      return "https://images.pexels.com/photos/4164765/pexels-photo-4164765.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("bicycle") || n.contains("mountain climber")) {
      return "https://images.pexels.com/photos/3775164/pexels-photo-3775164.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("ab wheel") || n.contains("rollout")) {
      return "https://images.pexels.com/photos/6456140/pexels-photo-6456140.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- CARDIO/FUNCTIONAL ---
    if (n.contains("burpee")) {
      return "https://images.pexels.com/photos/4498292/pexels-photo-4498292.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("jump") || n.contains("box jump")) {
      return "https://images.pexels.com/photos/4056535/pexels-photo-4056535.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("run") || n.contains("sprint") || n.contains("treadmill")) {
      return "https://images.pexels.com/photos/866021/pexels-photo-866021.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // --- STRETCHING/MOBILITY ---
    if (n.contains("stretch") || n.contains("foam roll")) {
      return "https://images.pexels.com/photos/3759658/pexels-photo-3759658.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    if (n.contains("yoga") || n.contains("downward dog") || n.contains("cobra")) {
      return "https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // ===========================================================
    // FALLBACK: Category-based images if no name match
    // ===========================================================
    String c = category.toLowerCase().trim();

    if (c.contains("barbell")) {
      return "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600";
    }
    if (c.contains("dumbbell")) {
      return "https://images.pexels.com/photos/3912944/pexels-photo-3912944.jpeg?auto=compress&cs=tinysrgb&w=600";
    }
    if (c.contains("cable") || c.contains("machine")) {
      return "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600";
    }
    if (c.contains("bodyweight")) {
      return "https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?auto=compress&cs=tinysrgb&w=600";
    }

    // Final fallback: Generic gym image
    return "https://images.pexels.com/photos/260352/pexels-photo-260352.jpeg?auto=compress&cs=tinysrgb&w=600";
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<String> parsedSteps = (json['steps'] != null) ? List<String>.from(json['steps']) : [];

    List<String> safeParse(dynamic field) {
      if (field == null) return [];
      if (field is List) return List<String>.from(field.map((e) => e.toString()));
      if (field is String) return [field];
      return [];
    }

    String? foundImage;
    if (json['og_image'] != null) foundImage = json['og_image'];
    else if (json['videos'] != null && (json['videos'] as List).isNotEmpty) {
      foundImage = json['videos'][0]['og_image'];
    }

    String? foundVideo;
    if (json['video'] != null && json['video'] is String) foundVideo = json['video'];
    else if (json['videos'] != null && (json['videos'] as List).isNotEmpty) {
      foundVideo = json['videos'][0]['url'];
    }

    return Exercise(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown",
      category: json['category'] ?? "",
      difficulty: json['difficulty'] ?? "",
      description: json['description'] ?? "",
      steps: parsedSteps,
      imageUrl: foundImage,
      videoUrl: foundVideo,
      targetMuscles: safeParse(json['primary_muscles'] ?? json['muscle']),
      grips: safeParse(json['grips']),
      force: json['force'],
      mechanic: json['mechanic'],
    );
  }

  // ✅ NEW: Factory for Firestore Manual Data
  factory Exercise.fromFirestore(Map<String, dynamic> data, String docId) {
    return Exercise(
      id: docId, // ✅ This is a String
      name: data['name'] ?? "Custom Exercise",
      category: data['muscleGroup'] ?? "Custom",
      difficulty: "Custom",
      description: data['instructions'] ?? "",
      steps: [data['instructions'] ?? ""],
      imageUrl: null, // Will use fallback
      videoUrl: data['videoUrl'],
      targetMuscles: [data['muscleGroup'] ?? "General"],
      grips: [],
      force: null,
      mechanic: null,
    );
  }
}

