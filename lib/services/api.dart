import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../model/model.dart';

class Api {

}

class PlanApiService {
  // Wger is 100% Free and Open Source. No Key needed.
  static const String baseUrl = "https://wger.de/api/v2";

  Future<List<dynamic>> getExercises() async {
    try {
      // 1. Use 'exerciseinfo' to get descriptions + names together
      // 2. 'language=2' forces English results only
      // 3. 'limit=50' gives you plenty of data
      final response = await http.get(
        Uri.parse("$baseUrl/exerciseinfo/?language=2&limit=50"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results']; // Wger puts the list inside 'results'
      } else {
        throw Exception("Failed to load: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}


//
// class WorkoutApiService {
//   static const String baseUrl = "https://exercisedb.p.rapidapi.com";
//
//   // Use the key you subscribed to
//   static const String apiKey = "8ed3afccfamsh526fb91fb118089p110fbbjsnaada4f16a265";
//
//   Future<List<dynamic>> getExercises() async {
//     try {
//       final response = await http.get(
//         Uri.parse("$baseUrl/exercises?limit=20"),
//         headers: {
//           'X-RapidAPI-Key': apiKey,
//           'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data is List) {
//           return data;
//         } else {
//           return [];
//         }
//       } else {
//         throw Exception("Failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Error fetching data: $e");
//     }
//   }
// }


class WorkoutApiService {
  // 1. NEW BASE URL (Direct Public Server)
  static const String baseUrl = "https://www.exercisedb.dev/api/v1";

  // 2. NO API KEY NEEDED (We removed the headers)

  // Fetch All Exercises
  Future<List<dynamic>> getExercises() async {
    // The public API limits usually default to 10 or 20.
    // We can try adding ?limit=50 if the API supports it, otherwise it loads defaults.
    return _fetchData("$baseUrl/exercises");
  }

  // Search Exercises (Using the endpoint you asked for)
  Future<List<dynamic>> searchExercises(String query) async {
    // According to your screenshot, the endpoint is /exercises/search?q={query}
    // NOT /exercises/name/{query} which was for RapidAPI.
    return _fetchData("$baseUrl/exercises/search?q=$query");
  }

  // Helper Function
  Future<List<dynamic>> _fetchData(String url) async {
    try {
      print("Calling: $url"); // Debug print to see what's happening

      final response = await http.get(
        Uri.parse(url),
        // 3. REMOVED HEADERS (No Key Required)
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // 4. HANDLE DIFFERENT DATA FORMATS
        // The public API sometimes returns { "data": [...] } or just [...]
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] != null) {
          return data['data']; // Extract the list from 'data' key
        } else if (data is Map && data['exercises'] != null) {
          return data['exercises'];
        } else {
          return [];
        }
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }
}


///weger\

class WgerApiService {
  static const String baseUrl = "https://wger.de/api/v2";

  // Get FULL exercise info with translations
  Future<List<dynamic>> getExercises() async {
    final url = "$baseUrl/exerciseinfo/?limit=100&language=2";
    return _fetchData(url);
  }

  // Get all exercise categories
  Future<List<dynamic>> getCategories() async {
    final url = "$baseUrl/exercisecategory/";
    return _fetchData(url);
  }

  // Get exercises by category ID
  Future<List<dynamic>> getExercisesByCategory(int categoryId) async {
    final url = "$baseUrl/exerciseinfo/?limit=100&language=2&category=$categoryId";
    return _fetchData(url);
  }

  // Get muscles list
  Future<List<dynamic>> getMuscles() async {
    final url = "$baseUrl/muscle/";
    return _fetchData(url);
  }

  // Get equipment list
  Future<List<dynamic>> getEquipment() async {
    final url = "$baseUrl/equipment/";
    return _fetchData(url);
  }

  Future<List<dynamic>> getVideos() async {
    final url = "$baseUrl/video/?limit=100";
    return _fetchData(url);
  }

  Future<List<dynamic>> getImages() async {
    final url = "$baseUrl/exerciseimage/?limit=100";
    return _fetchData(url);
  }

  // ==========================================
  // NUTRITION ENDPOINTS (PUBLIC ACCESS)
  // ==========================================

  // Get ingredients list (PUBLIC - No auth needed)
  Future<List<dynamic>> getIngredients({int limit = 50}) async {
    final url = "$baseUrl/ingredient/?limit=$limit";
    return _fetchData(url);
  }

  // Search ingredients by name
  Future<List<dynamic>> searchIngredients(String searchTerm) async {
    final url = "$baseUrl/ingredient/?search=$searchTerm&limit=20";
    return _fetchData(url);
  }

  // Get ingredient info
  Future<Map<String, dynamic>?> getIngredientInfo(int ingredientId) async {
    try {
      final url = "$baseUrl/ingredientinfo/$ingredientId/";
      print("🌐 Fetching: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ Error: Status ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching ingredient info: $e");
      return null;
    }
  }

  // Get meals/recipes (PUBLIC)
  Future<List<dynamic>> getMeals({int limit = 50}) async {
    final url = "$baseUrl/meal/?limit=$limit";
    return _fetchData(url);
  }

  // CUSTOM: Create local nutrition plan (stored in Firebase instead of Wger)
  // This way we don't need Wger authentication
  Future<Map<String, dynamic>> createLocalNutritionPlan(String description) async {
    // Return a template plan structure
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'description': description,
      'creation_date': DateTime.now().toIso8601String(),
      'calories': 0,
      'protein': 0,
      'carbohydrates': 0,
      'fat': 0,
      'meals': [],
    };
  }

  Future<List<dynamic>> _fetchData(String url) async {
    try {
      print("🌐 Fetching: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] ?? [];
        print("✅ Fetched ${results.length} items from $url");
        return results;
      } else {
        print("❌ Error: Status ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
      return [];
    }
  }
}


// ==========================================
// FATSECRET API SERVICE (with Fallback Autocomplete)
// ==========================================

class FatSecretNutritionService {
  static const String _consumerKey = '94ee4d57ea074df8b24e3708cce9bd8d';
  static const String _consumerSecret = 'fbccf896d0ef4c2cbe86db4e885688c2';
  static const String _baseUrl = 'https://platform.fatsecret.com/rest/server.api';

  // Generate OAuth 1.0 signature
  String _generateSignature(String method, String url, Map<String, String> params) {
    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    final paramString = sortedParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final baseString = '$method&${Uri.encodeComponent(url)}&${Uri.encodeComponent(paramString)}';
    final signingKey = '${Uri.encodeComponent(_consumerSecret)}&';
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final signature = base64.encode(hmac.convert(utf8.encode(baseString)).bytes);

    return signature;
  }

  // Make authenticated request to FatSecret API
  Future<Map<String, dynamic>> _makeRequest(Map<String, String> params) async {
    try {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final nonce = timestamp + (DateTime.now().microsecondsSinceEpoch % 1000).toString();

      final oauthParams = {
        ...params,
        'oauth_consumer_key': _consumerKey,
        'oauth_signature_method': 'HMAC-SHA1',
        'oauth_timestamp': timestamp,
        'oauth_nonce': nonce,
        'oauth_version': '1.0',
        'format': 'json',
      };

      final signature = _generateSignature('GET', _baseUrl, oauthParams);
      oauthParams['oauth_signature'] = signature;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: oauthParams);

      final response = await http.get(uri);

      print('📡 API Request: ${params['method']}');
      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Debug: Print response structure for debugging
        if (decoded is Map) {
          print('📋 Response keys: ${decoded.keys.toList()}');
        }

        return decoded;
      } else {
        print('❌ Error response (${response.statusCode}): ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Exception in _makeRequest: $e');
      return {};
    }
  }

  // ⚠️ PREMIUM FEATURE: Get food sub-categories for a category
  // Note: This requires FatSecret Premier API access
  // For Basic tier users, this will return an error
  Future<List<FoodSubCategory>> getFoodSubCategories(String categoryId) async {
    try {
      print('🔍 Fetching sub-categories for category: $categoryId');
      print('⚠️ Note: Sub-categories require Premier API access');

      final data = await _makeRequest({
        'method': 'food_sub_categories.get.v2',
        'food_category_id': categoryId,
      });

      print('📦 Raw sub-categories response: $data');

      // Check for error (likely "Unknown method" on Basic tier)
      if (data['error'] != null) {
        print('⚠️ API error: ${data['error']['message']}');
        print('💡 Tip: Sub-categories require Premier API tier');
        return [];
      }

      if (data['food_sub_categories'] != null &&
          data['food_sub_categories']['food_sub_category'] != null) {
        final subCats = data['food_sub_categories']['food_sub_category'];

        print('📋 Sub-categories data type: ${subCats.runtimeType}');

        List<FoodSubCategory> subCategories = [];
        if (subCats is List) {
          subCategories = subCats
              .map((json) => FoodSubCategory.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } else if (subCats is Map) {
          subCategories = [FoodSubCategory.fromJson(Map<String, dynamic>.from(subCats))];
        }

        print('✅ Loaded ${subCategories.length} sub-categories');
        return subCategories;
      }

      print('ℹ️ No sub-categories found for category $categoryId');
      return [];
    } catch (e) {
      print('❌ Exception in getFoodSubCategories: $e');
      return [];
    }
  }

  // Autocomplete using foods.search with limited results
  Future<List<String>> autocompleteFoodSearch(String expression) async {
    if (expression.isEmpty || expression.length < 2) return [];

    try {
      final data = await _makeRequest({
        'method': 'foods.search',
        'search_expression': expression,
        'max_results': '10',
        'page_number': '0',
      });

      List<String> suggestions = [];

      if (data['foods'] != null && data['foods']['food'] != null) {
        final foods = data['foods']['food'];

        if (foods is List) {
          suggestions = foods.map((food) {
            String name = food['food_name'] ?? '';
            String brand = food['brand_name'] ?? '';

            if (brand.isNotEmpty && brand.toLowerCase() != 'generic') {
              return '$name ($brand)';
            }
            return name;
          }).where((s) => s.isNotEmpty).toList();
        } else if (foods is Map) {
          String name = foods['food_name'] ?? '';
          String brand = foods['brand_name'] ?? '';

          if (name.isNotEmpty) {
            if (brand.isNotEmpty && brand.toLowerCase() != 'generic') {
              suggestions = ['$name ($brand)'];
            } else {
              suggestions = [name];
            }
          }
        }
      }

      return suggestions;
    } catch (e) {
      print('Exception in autocompleteFoodSearch: $e');
      return [];
    }
  }

  // Search for food items
  Future<List<FoodItem>> searchFood(String query) async {
    final data = await _makeRequest({
      'method': 'foods.search',
      'search_expression': query,
      'max_results': '50',
    });

    if (data['foods'] != null && data['foods']['food'] != null) {
      final foods = data['foods']['food'];
      if (foods is List) {
        return foods.map((json) => FoodItem.fromJson(Map<String, dynamic>.from(json))).toList();
      } else if (foods is Map) {
        return [FoodItem.fromJson(Map<String, dynamic>.from(foods))];
      }
    }
    return [];
  }

  // Get detailed food information
  Future<FoodDetail?> getFoodDetail(String foodId) async {
    final data = await _makeRequest({
      'method': 'food.get.v2',
      'food_id': foodId,
    });

    if (data['food'] != null) {
      return FoodDetail.fromJson(Map<String, dynamic>.from(data['food']));
    }
    return null;
  }

  // Get nutrition plans
  Future<List<NutritionPlanModel>> getNutritionPlans() async {
    try {
      final samplePlan = NutritionPlanModel(
        id: '1',
        description: 'Sample Nutrition Plan',
        creationDate: DateTime.now().toString().split(' ')[0],
        energy: 2000,
        protein: 150,
        carbs: 200,
        fat: 65,
        fiber: 30,
        meals: [
          Meal(
            time: 'Breakfast',
            items: [
              MealItem(
                name: 'Oatmeal',
                amount: 100,
                calories: 389,
                protein: 17,
                carbs: 66,
                fat: 7,
              ),
            ],
          ),
        ],
      );

      return [samplePlan];
    } catch (e) {
      print('Exception in getNutritionPlans: $e');
      return [];
    }
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    final data = await _makeRequest({
      'method': 'recipes.search',
      'search_expression': query,
      'max_results': '50',
    });

    if (data['recipes'] != null && data['recipes']['recipe'] != null) {
      final recipes = data['recipes']['recipe'];
      if (recipes is List) {
        return recipes.map((json) => Recipe.fromJson(Map<String, dynamic>.from(json))).toList();
      } else if (recipes is Map) {
        return [Recipe.fromJson(Map<String, dynamic>.from(recipes))];
      }
    }
    return [];
  }

  // Get detailed recipe information
  Future<RecipeDetail?> getRecipeDetail(String recipeId) async {
    final data = await _makeRequest({
      'method': 'recipe.get.v2',
      'recipe_id': recipeId,
    });

    if (data['recipe'] != null) {
      return RecipeDetail.fromJson(Map<String, dynamic>.from(data['recipe']));
    }
    return null;
  }

  // Get food categories
  Future<List<FoodCategory>> getFoodCategories() async {
    try {
      final data = await _makeRequest({
        'method': 'food_categories.get.v2',
      });

      print('📦 Raw categories response: $data');

      if (data['food_categories'] != null &&
          data['food_categories']['food_category'] != null) {
        final cats = data['food_categories']['food_category'];

        print('📋 Categories data type: ${cats.runtimeType}');

        List<FoodCategory> categories = [];
        if (cats is List) {
          categories = cats
              .map((json) => FoodCategory.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } else if (cats is Map) {
          categories = [FoodCategory.fromJson(Map<String, dynamic>.from(cats))];
        }

        if (categories.isNotEmpty) {
          print('✅ Loaded ${categories.length} food categories from API');
          return categories;
        }
      }

      // Check if data has any other structure
      if (data.isNotEmpty) {
        print('⚠️ API returned data but in unexpected format: ${data.keys}');
      }

      print('⚠️ API categories not available, using predefined list');
      return _getPredefinedCategories();
    } catch (e) {
      print('❌ Exception in getFoodCategories: $e');
      return _getPredefinedCategories();
    }
  }

  // Predefined food categories (fallback)
  List<FoodCategory> _getPredefinedCategories() {
    return [
      FoodCategory(
        categoryId: '1',
        categoryName: 'Fruits',
        categoryDescription: 'Fresh fruits, dried fruits, and fruit products',
      ),
      FoodCategory(
        categoryId: '2',
        categoryName: 'Vegetables',
        categoryDescription: 'Fresh vegetables, leafy greens, and root vegetables',
      ),
      FoodCategory(
        categoryId: '3',
        categoryName: 'Meat & Poultry',
        categoryDescription: 'Beef, chicken, pork, lamb, and other meats',
      ),
      FoodCategory(
        categoryId: '4',
        categoryName: 'Fish & Seafood',
        categoryDescription: 'Fresh fish, shellfish, and seafood products',
      ),
      FoodCategory(
        categoryId: '5',
        categoryName: 'Dairy & Eggs',
        categoryDescription: 'Milk, cheese, yogurt, butter, and eggs',
      ),
      FoodCategory(
        categoryId: '6',
        categoryName: 'Breads & Cereals',
        categoryDescription: 'Bread, pasta, rice, cereal, and grains',
      ),
      FoodCategory(
        categoryId: '7',
        categoryName: 'Snacks & Sweets',
        categoryDescription: 'Chips, cookies, candy, and desserts',
      ),
      FoodCategory(
        categoryId: '8',
        categoryName: 'Beverages',
        categoryDescription: 'Drinks, juices, coffee, tea, and soda',
      ),
    ];
  }

  // Search by category
  Future<List<FoodItem>> searchFoodsByCategory(String categoryId) async {
    try {
      final searchTerm = _getCategorySearchTerm(categoryId);

      final data = await _makeRequest({
        'method': 'foods.search',
        'search_expression': searchTerm,
        'max_results': '50',
      });

      if (data['foods'] != null && data['foods']['food'] != null) {
        final foods = data['foods']['food'];
        if (foods is List) {
          return foods.map((json) => FoodItem.fromJson(Map<String, dynamic>.from(json))).toList();
        } else if (foods is Map) {
          return [FoodItem.fromJson(Map<String, dynamic>.from(foods))];
        }
      }
      return [];
    } catch (e) {
      print('Exception in searchFoodsByCategory: $e');
      return [];
    }
  }

  // ✅ NEW: Search by sub-category
  Future<List<FoodItem>> searchFoodsBySubCategory(String subCategoryId) async {
    try {
      print('🔍 Searching foods for sub-category: $subCategoryId');

      final data = await _makeRequest({
        'method': 'foods.search',
        'food_sub_category_id': subCategoryId,
        'max_results': '50',
      });

      if (data['foods'] != null && data['foods']['food'] != null) {
        final foods = data['foods']['food'];
        if (foods is List) {
          return foods.map((json) => FoodItem.fromJson(Map<String, dynamic>.from(json))).toList();
        } else if (foods is Map) {
          return [FoodItem.fromJson(Map<String, dynamic>.from(foods))];
        }
      }
      return [];
    } catch (e) {
      print('Exception in searchFoodsBySubCategory: $e');
      return [];
    }
  }

  // Map category ID to search term
  String _getCategorySearchTerm(String categoryId) {
    switch (categoryId) {
      case '1': return 'fruit';
      case '2': return 'vegetable';
      case '3': return 'chicken';
      case '4': return 'fish';
      case '5': return 'milk';
      case '6': return 'bread';
      case '7': return 'cookie';
      case '8': return 'juice';
      default: return 'food';
    }
  }

  // Get food by barcode
  Future<FoodDetail?> getFoodByBarcode(String barcode) async {
    try {
      print('🔍 Searching for barcode: $barcode');

      final data = await _makeRequest({
        'method': 'food.find_id_for_barcode.v2',
        'barcode': barcode,
      });

      if (data['food_id'] != null) {
        final foodId = data['food_id']['value'].toString();
        print('✅ Found food_id: $foodId');
        return await getFoodDetail(foodId);
      } else if (data['error'] != null) {
        print('❌ Barcode API error: ${data['error']}');
        return null;
      }

      return null;
    } catch (e) {
      print('Exception in getFoodByBarcode: $e');
      return null;
    }
  }

  // ✅ NEW: Get all recipe types
  // ✅ NEW: Get all recipe types
  Future<List<RecipeType>> getRecipeTypes() async {
    try {
      print('🔍 Fetching recipe types...');

      final data = await _makeRequest({
        'method': 'recipe_types.get',
      });

      print('📦 Raw recipe types response: $data');

      if (data['recipe_types'] != null && data['recipe_types']['recipe_type'] != null) {
        final types = data['recipe_types']['recipe_type'];

        List<RecipeType> recipeTypes = <RecipeType>[];  // ✅ Explicit type
        if (types is List) {
          recipeTypes = types
              .map((json) => RecipeType.fromJson(Map<String, dynamic>.from(json)))
              .toList()
              .cast<RecipeType>();  // ✅ Add explicit cast
        } else if (types is Map) {
          recipeTypes = <RecipeType>[RecipeType.fromJson(Map<String, dynamic>.from(types))];  // ✅ Explicit type
        }

        if (recipeTypes.isNotEmpty) {
          print('✅ Loaded ${recipeTypes.length} recipe types from API');
          return recipeTypes;
        }
      }

      print('⚠️ API recipe types not available, using predefined list');
      return _getPredefinedRecipeTypes();
    } catch (e) {
      print('❌ Exception in getRecipeTypes: $e');
      return _getPredefinedRecipeTypes();
    }
  }

// Predefined recipe types (fallback)
// Predefined recipe types (fallback)
  List<RecipeType> _getPredefinedRecipeTypes() {
    return <RecipeType>[  // ✅ Add explicit type here
      RecipeType(recipeTypeId: '1', recipeTypeName: 'Breakfast', recipeTypeDescription: 'Morning meals and breakfast dishes'),
      RecipeType(recipeTypeId: '2', recipeTypeName: 'Lunch', recipeTypeDescription: 'Midday meals and lunch dishes'),
      RecipeType(recipeTypeId: '3', recipeTypeName: 'Dinner', recipeTypeDescription: 'Evening meals and dinner dishes'),
      RecipeType(recipeTypeId: '4', recipeTypeName: 'Dessert', recipeTypeDescription: 'Sweet treats and desserts'),
      RecipeType(recipeTypeId: '5', recipeTypeName: 'Snack', recipeTypeDescription: 'Quick snacks and light bites'),
      RecipeType(recipeTypeId: '6', recipeTypeName: 'Appetizer', recipeTypeDescription: 'Starters and appetizers'),
      RecipeType(recipeTypeId: '7', recipeTypeName: 'Main Dish', recipeTypeDescription: 'Main course dishes'),
      RecipeType(recipeTypeId: '8', recipeTypeName: 'Side Dish', recipeTypeDescription: 'Side dishes and accompaniments'),
      RecipeType(recipeTypeId: '9', recipeTypeName: 'Beverage', recipeTypeDescription: 'Drinks and beverages'),
      RecipeType(recipeTypeId: '10', recipeTypeName: 'Vegetarian', recipeTypeDescription: 'Vegetarian recipes'),
      RecipeType(recipeTypeId: '11', recipeTypeName: 'Vegan', recipeTypeDescription: 'Plant-based vegan recipes'),
      RecipeType(recipeTypeId: '12', recipeTypeName: 'Low Carb', recipeTypeDescription: 'Low carbohydrate recipes'),
      RecipeType(recipeTypeId: '13', recipeTypeName: 'High Protein', recipeTypeDescription: 'Protein-rich recipes'),
      RecipeType(recipeTypeId: '14', recipeTypeName: 'Salad', recipeTypeDescription: 'Fresh salads and greens'),
      RecipeType(recipeTypeId: '15', recipeTypeName: 'Soup', recipeTypeDescription: 'Soups and broths'),
    ];
  }

// ✅ UPDATED: Search recipes by type (using search term mapping)
  Future<List<Recipe>> searchRecipesByType(String recipeTypeId) async {
    try {
      print('🔍 Searching recipes for type: $recipeTypeId');

      // Map recipe type ID to search term
      final searchTerm = _getRecipeTypeSearchTerm(recipeTypeId);

      final data = await _makeRequest({
        'method': 'recipes.search',
        'search_expression': searchTerm,
        'max_results': '50',
      });

      print('📦 Recipe search response for "$searchTerm"');

      if (data['recipes'] != null && data['recipes']['recipe'] != null) {
        final recipes = data['recipes']['recipe'];
        if (recipes is List) {
          return recipes.map((json) => Recipe.fromJson(Map<String, dynamic>.from(json))).toList();
        } else if (recipes is Map) {
          return [Recipe.fromJson(Map<String, dynamic>.from(recipes))];
        }
      }

      print('ℹ️ No recipes found for type "$searchTerm"');
      return [];
    } catch (e) {
      print('❌ Exception in searchRecipesByType: $e');
      return [];
    }
  }

// Map recipe type ID to search term
  String _getRecipeTypeSearchTerm(String recipeTypeId) {
    switch (recipeTypeId) {
      case '1': return 'breakfast';
      case '2': return 'lunch';
      case '3': return 'dinner';
      case '4': return 'dessert';
      case '5': return 'snack';
      case '6': return 'appetizer';
      case '7': return 'chicken';
      case '8': return 'salad';
      case '9': return 'smoothie';
      case '10': return 'vegetarian';
      case '11': return 'vegan';
      case '12': return 'keto';
      case '13': return 'protein';
      case '14': return 'salad';
      case '15': return 'soup';
      default: return 'recipe';
    }
  }
}



////-------------------------


// ✅ ADD THIS AFTER THE DIRECTIONS SECTION in RecipeDetailScreen

// Add to Plan Button (inside SliverToBoxAdapter, after directions)


