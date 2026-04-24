import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../model/model.dart';
import '../screen/nutrition/nutrition_screen.dart';
import '../screen/screen.dart';
import '../services/api.dart';



class NutritionController extends GetxController {
  final FatSecretNutritionService _apiService = FatSecretNutritionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var nutritionPlans = <NutritionPlanModel>[].obs;
  var searchResults = <FoodItem>[].obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNutritionPlans();
    _listenToPlanChanges();
  }

// ✅ FETCH NUTRITION PLANS FROM FIREBASE
  Future<void> fetchNutritionPlans() async {
    try {
      isLoading.value = true;
      final currentRole = AppConstants.role;
      final currentUid = _auth.currentUser?.uid;

      if (currentUid == null) {
        isLoading.value = false;
        return;
      }

      if (currentRole == 'admin') {
        // ✅ ADMIN: See ALL plans created by ANY trainer or admin
        final snapshot = await _firestore
            .collection('nutrition_plans')
            .orderBy('createdAt', descending: true)
            .get();

        final plans = snapshot.docs.map((doc) {
          return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
        }).toList();

        nutritionPlans.assignAll(plans);
        print('✅ Admin: Loaded ${plans.length} plans from ALL trainers');

      } else if (currentRole == 'trainer') {
        // ✅ TRAINER: Only see their own plans
        final snapshot = await _firestore
            .collection('nutrition_plans')
            .where('createdBy', isEqualTo: currentUid)
            .orderBy('createdAt', descending: true)
            .get();

        final plans = snapshot.docs.map((doc) {
          return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
        }).toList();

        nutritionPlans.assignAll(plans);
        print('✅ Trainer: Loaded ${plans.length} own plans from Firebase');

      } else {
        // ✅ STUDENT: Only see assigned plans
        final assignmentsSnapshot = await _firestore
            .collection('nutrition_plan_assignments')
            .where('assignedUsers', arrayContains: currentUid)
            .get();

        if (assignmentsSnapshot.docs.isEmpty) {
          nutritionPlans.clear();
          print('✅ Student: No assigned plans');
          isLoading.value = false;
          return;
        }

        // Get plan IDs
        final planIds = assignmentsSnapshot.docs.map((doc) => doc.id).toList();

        // Fetch actual plans
        final plansSnapshot = await _firestore
            .collection('nutrition_plans')
            .where(FieldPath.documentId, whereIn: planIds)
            .get();

        final plans = plansSnapshot.docs.map((doc) {
          return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
        }).toList();

        nutritionPlans.assignAll(plans);
        print('✅ Student: Loaded ${plans.length} assigned plans from Firebase');
      }

      isLoading.value = false;
    } catch (e) {
      print('❌ Error fetching nutrition plans: $e');
      isLoading.value = false;
    }
  }

// ✅ LISTEN TO REAL-TIME PLAN CHANGES
  void _listenToPlanChanges() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    final currentRole = AppConstants.role;

    if (currentRole == 'admin') {
      // ✅ ADMIN: Listen to ALL plans
      _firestore
          .collection('nutrition_plans')
          .snapshots()
          .listen((snapshot) {
        final plans = snapshot.docs.map((doc) {
          return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
        }).toList();
        nutritionPlans.assignAll(plans);
        print('🔄 Admin: Plans updated - ${plans.length} total plans');
      });

    } else if (currentRole == 'trainer') {
      // ✅ TRAINER: Listen to own plans only
      _firestore
          .collection('nutrition_plans')
          .where('createdBy', isEqualTo: currentUid)
          .snapshots()
          .listen((snapshot) {
        final plans = snapshot.docs.map((doc) {
          return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
        }).toList();
        nutritionPlans.assignAll(plans);
        print('🔄 Trainer: Plans updated - ${plans.length} own plans');
      });

    } else {
      // ✅ STUDENT: Listen to assignments first, then plans
      _firestore
          .collection('nutrition_plan_assignments')
          .where('assignedUsers', arrayContains: currentUid)
          .snapshots()
          .listen((assignmentSnapshot) async {
        if (assignmentSnapshot.docs.isEmpty) {
          nutritionPlans.clear();
          return;
        }

        final planIds = assignmentSnapshot.docs.map((doc) => doc.id).toList();

        // Listen to actual plans
        _firestore
            .collection('nutrition_plans')
            .where(FieldPath.documentId, whereIn: planIds)
            .snapshots()
            .listen((planSnapshot) {
          final plans = planSnapshot.docs.map((doc) {
            return NutritionPlanModel.fromFirestore(doc.data(), doc.id);
          }).toList();
          nutritionPlans.assignAll(plans);
          print('🔄 Student: Plans updated - ${plans.length} assigned plans');
        });
      });
    }
  }

// ✅ NEW: Filter plans for students
  void _filterPlansForStudent(Set<String> assignedPlanIds) {
    if (AppConstants.role == 'trainer' || AppConstants.role == 'admin') {
      // Trainers/Admins see all plans (no filter)
      return;
    }

    // For students: Only show assigned plans
    final allPlans = nutritionPlans.toList();
    final filteredPlans = allPlans.where((plan) {
      bool isAssigned = assignedPlanIds.contains(plan.id);
      print('   Plan: ${plan.description} (${plan.id}) - Assigned: $isAssigned');
      return isAssigned;
    }).toList();

    nutritionPlans.assignAll(filteredPlans);
    print('✅ Filtered plans: ${filteredPlans.length}/${allPlans.length}');
  }


  // Get autocomplete suggestions
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    try {
      return await _apiService.autocompleteFoodSearch(query);
    } catch (e) {
      print('Error getting autocomplete suggestions: $e');
      return [];
    }
  }

  // FatSecret API methods
  Future<void> searchFood(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      var results = await _apiService.searchFood(query);
      searchResults.assignAll(results);
    } finally {
      isSearching.value = false;
    }
  }

  Future<FoodDetail?> getFoodDetail(String foodId) async {
    return await _apiService.getFoodDetail(foodId);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    return await _apiService.searchRecipes(query);
  }

  Future<RecipeDetail?> getRecipeDetail(String recipeId) async {
    return await _apiService.getRecipeDetail(recipeId);
  }

  // Get food by barcode
  Future<FoodDetail?> getFoodByBarcode(String barcode) async {
    try {
      return await _apiService.getFoodByBarcode(barcode);
    } catch (e) {
      print('Error getting food by barcode: $e');
      return null;
    }
  }

  // Get all food categories
  Future<List<FoodCategory>> getFoodCategories() async {
    try {
      return await _apiService.getFoodCategories();
    } catch (e) {
      print('Error getting food categories: $e');
      return [];
    }
  }

  // ✅ NEW: Get food sub-categories for a category
  Future<List<FoodSubCategory>> getFoodSubCategories(String categoryId) async {
    try {
      return await _apiService.getFoodSubCategories(categoryId);
    } catch (e) {
      print('Error getting food sub-categories: $e');
      return [];
    }
  }

  // Search foods by category
  Future<List<FoodItem>> searchFoodsByCategory(String categoryId) async {
    try {
      return await _apiService.searchFoodsByCategory(categoryId);
    } catch (e) {
      print('Error searching foods by category: $e');
      return [];
    }
  }

  // ✅ NEW: Search foods by sub-category
  Future<List<FoodItem>> searchFoodsBySubCategory(String subCategoryId) async {
    try {
      return await _apiService.searchFoodsBySubCategory(subCategoryId);
    } catch (e) {
      print('Error searching foods by sub-category: $e');
      return [];
    }
  }

  // ✅ CREATE NEW PLAN IN FIREBASE
  Future<NutritionPlanModel> createNewPlan({String description = 'My Plan'}) async {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null) throw Exception('User not authenticated');

      final planId = _firestore.collection('nutrition_plans').doc().id;

      final plan = NutritionPlanModel(
        id: planId,
        description: description,
        creationDate: DateTime.now().toString().split(' ')[0],
        energy: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        fiber: 0,
        meals: [],
      );

      await _firestore.collection('nutrition_plans').doc(planId).set({
        'description': plan.description,
        'creationDate': plan.creationDate,
        'energy': plan.energy,
        'protein': plan.protein,
        'carbs': plan.carbs,
        'fat': plan.fat,
        'fiber': plan.fiber,
        'meals': [],
        'createdBy': currentUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Created new plan in Firebase: ${plan.description}');
      return plan;
    } catch (e) {
      print('❌ Error creating plan: $e');
      rethrow;
    }
  }

  Future<void> updatePlanDescription(String planId, String newDescription) async {
    try {
      await _firestore.collection('nutrition_plans').doc(planId).update({
        'description': newDescription,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Updated plan description in Firebase: $newDescription');
    } catch (e) {
      print('❌ Error updating plan: $e');
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _firestore.collection('nutrition_plans').doc(planId).delete();
      await _firestore.collection('nutrition_plan_assignments').doc(planId).delete();
      print('✅ Deleted plan from Firebase: $planId');
    } catch (e) {
      print('❌ Error deleting plan: $e');
    }
  }

  Future<void> addFoodToPlan(
      String planId,
      FoodDetail food, {
        String mealTime = 'Breakfast',
        double servings = 1,
      }) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();

      if (!planDoc.exists) {
        print('❌ Plan not found');
        return;
      }

      final planData = planDoc.data()!;
      final List<dynamic> mealsData = planData['meals'] ?? [];

      List<Meal> meals = mealsData.map((m) => Meal.fromJson(Map<String, dynamic>.from(m))).toList();

      var mealIndex = meals.indexWhere((m) => m.time == mealTime);

      final newItem = MealItem(
        name: food.foodName,
        amount: servings,
        calories: food.calories * servings,
        protein: food.protein * servings,
        carbs: food.carbs * servings,
        fat: food.fat * servings,
      );

      if (mealIndex == -1) {
        meals.add(Meal(time: mealTime, items: [newItem]));
      } else {
        meals[mealIndex] = Meal(
          time: meals[mealIndex].time,
          items: [...meals[mealIndex].items, newItem],
        );
      }

      double totalEnergy = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      for (var meal in meals) {
        for (var item in meal.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Added ${food.foodName} to $mealTime in Firebase');
    } catch (e) {
      print('❌ Error adding food to plan: $e');
    }
  }

  Future<void> updateFoodItemQuantity(String planId, String mealTime, String itemName, double newAmount) async {
    try {
      // 1. Get current plan index
      final planIndex = nutritionPlans.indexWhere((p) => p.id == planId);
      if (planIndex == -1) return;

      final oldPlan = nutritionPlans[planIndex];

      // 2. Find meal
      final mealIndex = oldPlan.meals.indexWhere((m) => m.time == mealTime);
      if (mealIndex == -1) return;

      // 3. Find food item
      final meal = oldPlan.meals[mealIndex];
      final itemIndex = meal.items.indexWhere((item) => item.name == itemName);
      if (itemIndex == -1) return;

      final oldItem = meal.items[itemIndex];

      // 4. Create NEW item with updated macros
      final newItem = MealItem(
        name: oldItem.name,
        amount: newAmount,
        calories: (oldItem.calories / oldItem.amount) * newAmount,
        protein: (oldItem.protein / oldItem.amount) * newAmount,
        carbs: (oldItem.carbs / oldItem.amount) * newAmount,
        fat: (oldItem.fat / oldItem.amount) * newAmount,
        // Keep recipe details
        isRecipe: oldItem.isRecipe,
        recipeId: oldItem.recipeId,
        image: oldItem.image,
        ingredients: oldItem.ingredients,
        directions: oldItem.directions,
        description: oldItem.description,
      );

      // 5. Update the item in the meals list
      // Note: We need to modify the list in memory first to calculate totals
      oldPlan.meals[mealIndex].items[itemIndex] = newItem;

      // ---------------------------------------------------------
      // ⚠️ NEW STEP: Recalculate Totals for the WHOLE Plan
      // ---------------------------------------------------------
      double totalEnergy = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (var m in oldPlan.meals) {
        for (var item in m.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      // 6. Create a NEW Plan Object with updated totals
      // (Because 'energy', 'protein' etc. are final fields, we must create a new object)
      final updatedPlan = NutritionPlanModel(
        id: oldPlan.id,
        description: oldPlan.description,
        creationDate: oldPlan.creationDate,
        energy: totalEnergy,      // ✅ Updated Total
        protein: totalProtein,    // ✅ Updated Total
        carbs: totalCarbs,        // ✅ Updated Total
        fat: totalFat,            // ✅ Updated Total
        fiber: oldPlan.fiber,
        meals: oldPlan.meals,     // Updated meals list
        createdBy: oldPlan.createdBy,
        createdAt: oldPlan.createdAt,
        updatedAt: DateTime.now(),
      );

      // 7. Update Local State (UI updates immediately)
      nutritionPlans[planIndex] = updatedPlan;
      nutritionPlans.refresh();

      // 8. Update Firestore
      await FirebaseFirestore.instance.collection('nutrition_plans').doc(planId).update({
        'meals': oldPlan.meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,    // ✅ Save to DB
        'protein': totalProtein,  // ✅ Save to DB
        'carbs': totalCarbs,      // ✅ Save to DB
        'fat': totalFat,          // ✅ Save to DB
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print("Error updating quantity: $e");
      Get.snackbar("Error", "Could not update quantity");
    }
  }

  Future<void> removeFoodItemFromPlan(
      String planId,
      String mealTime,
      String foodName,
      ) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();
      if (!planDoc.exists) return;

      final planData = planDoc.data()!;
      List<Meal> meals = (planData['meals'] as List<dynamic>)
          .map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      final mealIndex = meals.indexWhere((m) => m.time == mealTime);
      if (mealIndex == -1) return;

      meals[mealIndex].items.removeWhere((item) => item.name == foodName);

      if (meals[mealIndex].items.isEmpty) {
        meals.removeAt(mealIndex);
      }

      double totalEnergy = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      for (var meal in meals) {
        for (var item in meal.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Removed food item from Firebase');
    } catch (e) {
      print('❌ Error removing food item: $e');
    }
  }

  Future<void> deleteEntireMeal(String planId, String mealTime) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();
      if (!planDoc.exists) return;

      final planData = planDoc.data()!;
      List<Meal> meals = (planData['meals'] as List<dynamic>)
          .map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      meals.removeWhere((m) => m.time == mealTime);

      double totalEnergy = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      for (var meal in meals) {
        for (var item in meal.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Deleted entire meal from Firebase');
    } catch (e) {
      print('❌ Error deleting meal: $e');
    }
  }

  // ✅ ASSIGN PLAN TO USERS (Trainer/Admin only)
  Future<void> assignPlanToUsers(String planId, List<String> userIds) async {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null) throw Exception('User not authenticated');

      await _firestore.collection('nutrition_plan_assignments').doc(planId).set({
        'planId': planId,
        'assignedUsers': userIds,
        'assignedBy': currentUid,
        'assignedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Assigned plan to ${userIds.length} users');
    } catch (e) {
      print('❌ Error assigning plan: $e');
    }
  }




  // ✅ FIXED: Return proper type List<RecipeType>
  Future<List<RecipeType>> getRecipeTypes() async {
    try {
      return await _apiService.getRecipeTypes();
    } catch (e) {
      print('Error getting recipe types: $e');
      return <RecipeType>[];
    }
  }

// ✅ NEW: Search recipes by type
  Future<List<Recipe>> searchRecipesByType(String recipeTypeId) async {
    try {
      return await _apiService.searchRecipesByType(recipeTypeId);
    } catch (e) {
      print('Error searching recipes by type: $e');
      return [];
    }
  }

  // ✅ ADD THIS METHOD to NutritionController

// Add recipe to nutrition plan
  // Inside NutritionController class...

  Future<void> addRecipeToPlan(
      String planId,
      RecipeDetail recipe, {
        String mealTime = 'Breakfast',
        double servings = 1,
      }) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();
      if (!planDoc.exists) return;

      final planData = planDoc.data()!;
      List<Meal> meals = (planData['meals'] as List<dynamic>)
          .map((m) => Meal.fromJson(Map<String, dynamic>.from(m))).toList();

      var mealIndex = meals.indexWhere((m) => m.time == mealTime);

      // ✅ FIX: Safe String Interpolation for Ingredients
      List<String> ingredientList = recipe.ingredients.map((i) {
        // If measurement is empty, just show the ingredient name
        if (i.measurementDescription.isEmpty) {
          return "${i.numberOfUnits} ${i.ingredientDescription}";
        }
        return "${i.numberOfUnits} ${i.measurementDescription} ${i.ingredientDescription}";
      }).toList();

      // ✅ Safe String Interpolation for Directions
      List<String> directionList = recipe.directions
          .map((d) => d.directionDescription)
          .toList();

      final nutrition = recipe.nutrition;
      final newItem = MealItem(
        name: recipe.recipeName,
        amount: servings,
        calories: nutrition.calories * servings,
        protein: nutrition.protein * servings,
        carbs: nutrition.carbs * servings,
        fat: nutrition.fat * servings,
        isRecipe: true,
        recipeId: recipe.recipeId,
        // ✅ SAVE FULL DETAILS
        image: recipe.recipeImage,
        description: recipe.recipeDescription,
        ingredients: ingredientList,
        directions: directionList,
      );

      if (mealIndex == -1) {
        meals.add(Meal(time: mealTime, items: [newItem]));
      } else {
        meals[mealIndex] = Meal(
          time: meals[mealIndex].time,
          items: [...meals[mealIndex].items, newItem],
        );
      }

      // Recalculate Totals
      double totalEnergy = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      for (var meal in meals) {
        for (var item in meal.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Full Recipe Saved to Firebase!');
    } catch (e) {
      print('❌ Error adding recipe: $e');
    }
  }

  Future<void> updateMealItemInPlan(
      String planId, String mealTime, MealItem oldItem, MealItem newItem) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();
      if (!planDoc.exists) return;

      final planData = planDoc.data()!;
      List<Meal> meals = (planData['meals'] as List<dynamic>)
          .map((m) => Meal.fromJson(Map<String, dynamic>.from(m))).toList();

      var mealIndex = meals.indexWhere((m) => m.time == mealTime);
      if (mealIndex == -1) return;

      // Find and Replace the Item
      var itemIndex = meals[mealIndex].items.indexWhere((i) =>
      i.name == oldItem.name && i.calories == oldItem.calories); // Match by name/cal

      if (itemIndex != -1) {
        meals[mealIndex].items[itemIndex] = newItem;
      }

      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error updating item: $e");
    }
  }

  // ✅ NEW: Fetch a single plan by ID
  Future<NutritionPlanModel?> fetchPlanById(String planId) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();

      if (!planDoc.exists) {
        print('❌ Plan not found: $planId');
        return null;
      }

      print('✅ Fetched plan: $planId');
      return NutritionPlanModel.fromFirestore(planDoc.data()!, planDoc.id);
    } catch (e) {
      print('❌ Error fetching plan by ID: $e');
      return null;
    }
  }

// ✅ NEW: Add MealItem directly to plan (used for scanned foods)
  Future<void> addMealItemToPlan(
      String planId,
      String mealTime,
      MealItem mealItem,
      ) async {
    try {
      final planDoc = await _firestore.collection('nutrition_plans').doc(planId).get();

      if (!planDoc.exists) {
        print('❌ Plan not found');
        return;
      }

      final planData = planDoc.data()!;
      final List<dynamic> mealsData = planData['meals'] ?? [];

      List<Meal> meals = mealsData.map((m) => Meal.fromJson(Map<String, dynamic>.from(m))).toList();

      var mealIndex = meals.indexWhere((m) => m.time == mealTime);

      if (mealIndex == -1) {
        // Create new meal
        meals.add(Meal(time: mealTime, items: [mealItem]));
      } else {
        // Add to existing meal
        meals[mealIndex] = Meal(
          time: meals[mealIndex].time,
          items: [...meals[mealIndex].items, mealItem],
        );
      }

      // Recalculate totals
      double totalEnergy = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      for (var meal in meals) {
        for (var item in meal.items) {
          totalEnergy += item.calories;
          totalProtein += item.protein;
          totalCarbs += item.carbs;
          totalFat += item.fat;
        }
      }

      // Update Firebase
      await _firestore.collection('nutrition_plans').doc(planId).update({
        'meals': meals.map((m) => m.toJson()).toList(),
        'energy': totalEnergy,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Added meal item "${mealItem.name}" to $mealTime in Firebase');
    } catch (e) {
      print('❌ Error adding meal item to plan: $e');
      rethrow;
    }
  }

}


class RecipeController extends GetxController {
  final FatSecretNutritionService _apiService = FatSecretNutritionService();

  var isSearching = false.obs;
  var searchResults = <Recipe>[].obs;
  var selectedRecipe = Rxn<RecipeDetail>();
  var isLoadingDetail = false.obs;

  // Search for recipes
  void searchRecipes(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      var results = await _apiService.searchRecipes(query);
      searchResults.assignAll(results);
    } finally {
      isSearching.value = false;
    }
  }

  // Get detailed recipe info
  Future<void> loadRecipeDetail(String recipeId) async {
    try {
      isLoadingDetail.value = true;
      var detail = await _apiService.getRecipeDetail(recipeId);
      selectedRecipe.value = detail;
    } finally {
      isLoadingDetail.value = false;
    }
  }
}




