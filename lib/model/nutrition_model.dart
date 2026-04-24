import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;




// ==========================================
// NUTRITION PLAN MODEL WITH FIREBASE SUPPORT
// ==========================================

class NutritionPlanModel   {
  final String id;
  final String description;
  final String creationDate;
  final double energy;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final List<Meal> meals;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NutritionPlanModel({
    required this.id,
    required this.description,
    required this.creationDate,
    required this.energy,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.meals = const [],
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ FROM FIREBASE FIRESTORE
  factory NutritionPlanModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return NutritionPlanModel(
      id: docId,
      description: data['description'] ?? 'Nutrition Plan',
      creationDate: data['creationDate'] ?? '',
      energy: _parseDouble(data['energy']),
      protein: _parseDouble(data['protein']),
      carbs: _parseDouble(data['carbs']),
      fat: _parseDouble(data['fat']),
      fiber: _parseDouble(data['fiber']),
      meals: (data['meals'] as List<dynamic>?)
          ?.map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
          .toList() ?? [],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ✅ TO FIREBASE FIRESTORE
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'creationDate': creationDate,
      'energy': energy,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'meals': meals.map((m) => m.toJson()).toList(),
      'createdBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // FROM JSON (for FatSecret API)
  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) {
    return NutritionPlanModel(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? 'Nutrition Plan',
      creationDate: json['creation_date'] ?? json['date'] ?? '',
      energy: _parseDouble(json['calories'] ?? json['energy']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbohydrates'] ?? json['carbs']),
      fat: _parseDouble(json['fat']),
      fiber: _parseDouble(json['fiber']),
      meals: (json['meals'] as List<dynamic>?)
          ?.map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
          .toList() ?? [],
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'creation_date': creationDate,
      'calories': energy,
      'protein': protein,
      'carbohydrates': carbs,
      'fat': fat,
      'fiber': fiber,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ==========================================
// UPDATED MEAL MODELS WITH RECIPE SUPPORT
// ==========================================

class Meal {
  final String time;
  final List<MealItem> items;

  Meal({
    required this.time,
    this.items = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      time: json['time'] ?? json['meal_name'] ?? 'Meal',
      items: (json['meal_items'] as List<dynamic>?)
          ?.map((i) => MealItem.fromJson(Map<String, dynamic>.from(i)))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'meal_items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class MealItem {
  final String name;
  final double amount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool isRecipe;
  final String? recipeId;
  // ✅ NEW FIELDS FOR LOCAL STORAGE
  final String? image;
  final String? description;
  final List<String>? ingredients; // Store as list of strings for simplicity
  final List<String>? directions;  // Store as list of strings

  MealItem({
    required this.name,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isRecipe = false,
    this.recipeId,
    this.image,
    this.description,
    this.ingredients,
    this.directions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'isRecipe': isRecipe,
      'recipeId': recipeId,
      // ✅ SAVE NEW FIELDS
      'image': image,
      'description': description,
      'ingredients': ingredients,
      'directions': directions,
    };
  }

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 1.0).toDouble(),
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      isRecipe: json['isRecipe'] ?? false,
      recipeId: json['recipeId'],
      // ✅ LOAD NEW FIELDS
      image: json['image'],
      description: json['description'],
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : null,
      directions: json['directions'] != null ? List<String>.from(json['directions']) : null,
    );
  }

  // ✅ Helper method to create from Recipe
  factory MealItem.fromRecipe(RecipeDetail recipe, double servings) {
    final nutrition = recipe.nutrition;
    return MealItem(
      name: recipe.recipeName,
      amount: servings,
      calories: nutrition.calories * servings,
      protein: nutrition.protein * servings,
      carbs: nutrition.carbs * servings,
      fat: nutrition.fat * servings,
      isRecipe: true,
      recipeId: recipe.recipeId,
    );
  }
}

// Food search result model
class FoodItem {
  final String foodId;
  final String foodName;
  final String foodType;
  final String brandName;
  final String foodDescription;

  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.foodType,
    this.brandName = '',
    this.foodDescription = '',
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      foodType: json['food_type'] ?? 'Generic',
      brandName: json['brand_name'] ?? '',
      foodDescription: json['food_description'] ?? '',
    );
  }
}

// Detailed food information
class FoodDetail {
  final String foodId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String servingSize;

  FoodDetail({
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingSize,
  });

  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    final servings = json['servings'];
    final serving = servings is Map ? servings['serving'] : null;
    final nutritionData = serving is List ? serving[0] : (serving ?? {});

    return FoodDetail(
      foodId: json['food_id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      calories: _parseDouble(nutritionData['calories']),
      protein: _parseDouble(nutritionData['protein']),
      carbs: _parseDouble(nutritionData['carbohydrate']),
      fat: _parseDouble(nutritionData['fat']),
      fiber: _parseDouble(nutritionData['fiber']),
      servingSize: nutritionData['serving_description']?.toString() ?? '100g',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Add this model to your nutrition_model.dart file

class FoodCategory {
  final String categoryId;
  final String categoryName;
  final String categoryDescription;

  FoodCategory({
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription = '',
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      categoryId: json['food_category_id']?.toString() ?? '',
      categoryName: json['food_category_name'] ?? '',
      categoryDescription: json['food_category_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_category_id': categoryId,
      'food_category_name': categoryName,
      'food_category_description': categoryDescription,
    };
  }
}

// Add this to your models file

class FoodSubCategory {
  final String subCategoryId;
  final String subCategoryName;
  final String subCategoryDescription;

  FoodSubCategory({
    required this.subCategoryId,
    required this.subCategoryName,
    this.subCategoryDescription = '',
  });

  factory FoodSubCategory.fromJson(Map<String, dynamic> json) {
    return FoodSubCategory(
      subCategoryId: json['food_sub_category_id']?.toString() ?? '',
      subCategoryName: json['food_sub_category_name']?.toString() ?? '',
      subCategoryDescription: json['food_sub_category_description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_sub_category_id': subCategoryId,
      'food_sub_category_name': subCategoryName,
      'food_sub_category_description': subCategoryDescription,
    };
  }
}



class FoodAnalysisResult {
  final String foodName;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portionSize;
  final String confidence;

  FoodAnalysisResult({
    required this.foodName,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portionSize,
    required this.confidence,
  });

  factory FoodAnalysisResult.fromGeminiResponse(String jsonResponse) {
    try {
      // Remove markdown code blocks if present
      String cleaned = jsonResponse.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final Map<String, dynamic> json = jsonDecode(cleaned);

      return FoodAnalysisResult(
        foodName: json['foodName'] ?? 'Unknown Food',
        description: json['description'] ?? '',
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        portionSize: json['portionSize'] ?? 'Unknown',
        confidence: json['confidence'] ?? 'Unknown confidence',
      );
    } catch (e) {
      print('❌ Parse Error: $e');
      print('❌ Response: $jsonResponse');
      throw Exception('Failed to parse Gemini response');
    }
  }
}



class Recipe {
  final String recipeId;
  final String recipeName;
  final String recipeDescription;
  final String recipeUrl;
  final List<String> recipeTypes;
  final String recipeImage;

  Recipe({
    required this.recipeId,
    required this.recipeName,
    this.recipeDescription = '',
    this.recipeUrl = '',
    this.recipeTypes = const [],
    this.recipeImage = '',
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> types = [];
    if (json['recipe_types'] != null) {
      final recipeTypes = json['recipe_types']['recipe_type'];
      if (recipeTypes is List) {
        types = recipeTypes.map((t) => t.toString()).toList();
      } else if (recipeTypes is String) {
        types = [recipeTypes];
      }
    }

    // ✅ FIXED: Parse recipe image (can be String or List)
    String imageUrl = '';
    if (json['recipe_images'] != null) {
      final images = json['recipe_images']['recipe_image'];
      if (images is String) {
        imageUrl = images;
      } else if (images is List && images.isNotEmpty) {
        imageUrl = images[0].toString();
      } else if (images is Map && images['image'] != null) {
        imageUrl = images['image'].toString();
      }
    }
    if (imageUrl.isEmpty && json['recipe_image'] != null) {
      imageUrl = json['recipe_image'].toString();
    }

    return Recipe(
      recipeId: json['recipe_id']?.toString() ?? '',
      recipeName: json['recipe_name'] ?? '',
      recipeDescription: json['recipe_description'] ?? '',
      recipeUrl: json['recipe_url'] ?? '',
      recipeTypes: types,
      recipeImage: imageUrl,
    );
  }
}

class RecipeDetail {
  final String recipeId;
  final String recipeName;
  final String recipeDescription;
  final String recipeUrl;
  final String recipeImage;
  final List<String> recipeTypes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeDirection> directions;
  final RecipeNutrition nutrition;
  final int numberOfServings;
  final String preparationTime;
  final String cookingTime;

  RecipeDetail({
    required this.recipeId,
    required this.recipeName,
    required this.recipeDescription,
    required this.recipeUrl,
    required this.recipeImage,
    this.recipeTypes = const [],
    this.ingredients = const [],
    this.directions = const [],
    required this.nutrition,
    this.numberOfServings = 1,
    this.preparationTime = '',
    this.cookingTime = '',
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    // Parse recipe types
    List<String> types = [];
    if (json['recipe_types'] != null) {
      final recipeTypes = json['recipe_types']['recipe_type'];
      if (recipeTypes is List) {
        types = recipeTypes.map((t) => t.toString()).toList();
      } else if (recipeTypes is String) {
        types = [recipeTypes];
      }
    }

    // Parse ingredients
    List<RecipeIngredient> ingredients = [];
    if (json['ingredients'] != null && json['ingredients']['ingredient'] != null) {
      final ings = json['ingredients']['ingredient'];
      if (ings is List) {
        ingredients = ings.map((i) => RecipeIngredient.fromJson(Map<String, dynamic>.from(i))).toList();
      } else if (ings is Map) {
        ingredients = [RecipeIngredient.fromJson(Map<String, dynamic>.from(ings))];
      }
    }

    // Parse directions
    List<RecipeDirection> directions = [];
    if (json['directions'] != null && json['directions']['direction'] != null) {
      final dirs = json['directions']['direction'];
      if (dirs is List) {
        directions = dirs.map((d) => RecipeDirection.fromJson(Map<String, dynamic>.from(d))).toList();
      } else if (dirs is Map) {
        directions = [RecipeDirection.fromJson(Map<String, dynamic>.from(dirs))];
      }
    }

    // ✅ FIXED: Parse recipe image (can be String or List)
    String imageUrl = '';
    if (json['recipe_images'] != null) {
      final images = json['recipe_images']['recipe_image'];
      if (images is String) {
        // Single image as string
        imageUrl = images;
      } else if (images is List && images.isNotEmpty) {
        // Multiple images as list - take first one
        imageUrl = images[0].toString();
      } else if (images is Map && images['image'] != null) {
        // Image wrapped in object
        imageUrl = images['image'].toString();
      }
    }
    // Fallback to recipe_image field
    if (imageUrl.isEmpty && json['recipe_image'] != null) {
      imageUrl = json['recipe_image'].toString();
    }

    // Parse nutrition
    final nutritionData = json['serving_sizes']?['serving'] ?? {};
    final serving = nutritionData is List ? nutritionData[0] : nutritionData;

    return RecipeDetail(
      recipeId: json['recipe_id']?.toString() ?? '',
      recipeName: json['recipe_name'] ?? '',
      recipeDescription: json['recipe_description'] ?? '',
      recipeUrl: json['recipe_url'] ?? '',
      recipeImage: imageUrl,
      recipeTypes: types,
      ingredients: ingredients,
      directions: directions,
      nutrition: RecipeNutrition.fromJson(serving ?? {}),
      numberOfServings: int.tryParse(json['number_of_servings']?.toString() ?? '1') ?? 1,
      preparationTime: json['preparation_time']?.toString() ?? '',
      cookingTime: json['cooking_time']?.toString() ?? '',
    );
  }
}

class RecipeIngredient {
  final String ingredientDescription;
  final String ingredientUrl;
  final String foodId;
  final String measurementDescription; // ✅ ADD THIS FIELD
  final double numberOfUnits;

  RecipeIngredient({
    required this.ingredientDescription,
    this.ingredientUrl = '',
    this.foodId = '',
    required this.measurementDescription, // ✅ ADD THIS
    required this.numberOfUnits,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientDescription: json['ingredient_description'] ?? '',
      ingredientUrl: json['ingredient_url'] ?? '',
      foodId: json['food_id']?.toString() ?? '',
      // ✅ ADD THIS MAPPING (FatSecret usually uses 'measurement_description')
      measurementDescription: json['measurement_description'] ?? '',

      numberOfUnits: double.tryParse(json['number_of_units']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class RecipeDirection {
  final int directionNumber;
  final String directionDescription;

  RecipeDirection({
    required this.directionNumber,
    required this.directionDescription,
  });

  factory RecipeDirection.fromJson(Map<String, dynamic> json) {
    return RecipeDirection(
      directionNumber: int.tryParse(json['direction_number']?.toString() ?? '0') ?? 0,
      directionDescription: json['direction_description'] ?? '',
    );
  }
}

class RecipeNutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  RecipeNutrition({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbohydrate']),
      fat: _parseDouble(json['fat']),
      fiber: _parseDouble(json['fiber']),
      sugar: _parseDouble(json['sugar']),
      sodium: _parseDouble(json['sodium']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class RecipeType {
  final String recipeTypeId;
  final String recipeTypeName;
  final String recipeTypeDescription;

  RecipeType({
    required this.recipeTypeId,
    required this.recipeTypeName,
    required this.recipeTypeDescription,
  });

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(
      recipeTypeId: json['recipe_type_id']?.toString() ?? '',
      recipeTypeName: json['recipe_type']?.toString() ?? '',
      recipeTypeDescription: json['recipe_type_description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_type_id': recipeTypeId,
      'recipe_type': recipeTypeName,
      'recipe_type_description': recipeTypeDescription,
    };
  }
}



class RecipeItemModel {
  final String name;
  final double servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> planNames;
  final String? recipeId;

  RecipeItemModel({
    required this.name,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.planNames,
    this.recipeId,
  });
}



class RecipeAssignment {
  final String id;
  final String recipeId;
  final String recipeName;
  final String recipeDescription;
  final String recipeImage;
  final List<String> recipeTypes;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> assignedUsers;
  final String assignedBy;
  final String assignedDate;

  RecipeAssignment({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.recipeDescription,
    required this.recipeImage,
    required this.recipeTypes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.assignedUsers,
    required this.assignedBy,
    required this.assignedDate,
  });

  factory RecipeAssignment.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return RecipeAssignment(
      id: docId,
      recipeId: data['recipeId'] ?? '',
      recipeName: data['recipeName'] ?? 'Unknown Recipe',
      recipeDescription: data['recipeDescription'] ?? '',
      recipeImage: data['recipeImage'] ?? '',
      recipeTypes: List<String>.from(data['recipeTypes'] ?? []),
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      assignedUsers: List<String>.from(data['assignedUsers'] ?? []),
      assignedBy: data['assignedBy'] ?? '',
      assignedDate: data['assignedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeDescription': recipeDescription,
      'recipeImage': recipeImage,
      'recipeTypes': recipeTypes,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'assignedUsers': assignedUsers,
      'assignedBy': assignedBy,
      'assignedDate': assignedDate,
    };
  }
}
