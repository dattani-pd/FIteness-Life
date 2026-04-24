import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller.dart';
import '../../model/model.dart';
import '../screen.dart';

class FoodCategoriesScreen extends StatefulWidget {
  static const pageId = "/FoodCategoriesScreen";
  const FoodCategoriesScreen({super.key});

  @override
  State<FoodCategoriesScreen> createState() => _FoodCategoriesScreenState();
}

class _FoodCategoriesScreenState extends State<FoodCategoriesScreen> {
  final NutritionController controller = Get.find<NutritionController>();

  List<FoodCategory> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cats = await controller.getFoodCategories();
      if (mounted) {
        setState(() {
          categories = cats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color iconColor = isDark ? Colors.grey.shade400 : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Food Categories", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 80, color: iconColor),
            const SizedBox(height: 16),
            Text('No categories found', style: TextStyle(color: subText, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category, isDark);
        },
      ),
    );
  }

  Widget _buildCategoryCard(FoodCategory category, bool isDark) {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    final color = colors[int.parse(category.categoryId) % colors.length];

    // Dynamic Card Colors
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey[600]!;
    final Color arrowColor = isDark ? Colors.grey.shade500 : Colors.grey[400]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // ✅ Go directly to foods (sub-categories require Premier API)
          Get.to(() => CategoryFoodsScreen(category: category));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(isDark ? 0.2 : 0.1),
                color.withOpacity(isDark ? 0.1 : 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(category.categoryName),
                  color: color, // Use the base color for the icon itself
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.categoryName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (category.categoryDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.categoryDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: subTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: arrowColor),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('fruit')) return Icons.apple;
    if (name.contains('vegetable')) return Icons.grass;
    if (name.contains('meat') || name.contains('poultry')) return Icons.restaurant;
    if (name.contains('dairy')) return Icons.local_drink;
    if (name.contains('bread') || name.contains('grain')) return Icons.bakery_dining;
    if (name.contains('snack')) return Icons.cookie;
    if (name.contains('beverage') || name.contains('drink')) return Icons.local_cafe;
    if (name.contains('dessert') || name.contains('sweet')) return Icons.cake;
    if (name.contains('seafood') || name.contains('fish')) return Icons.set_meal;

    return Icons.restaurant_menu;
  }
}

/// CATEGORY FOODS LIST SCREEN
class CategoryFoodsScreen extends StatefulWidget {
  final FoodCategory category;

  const CategoryFoodsScreen({super.key, required this.category});

  @override
  State<CategoryFoodsScreen> createState() => _CategoryFoodsScreenState();
}

class _CategoryFoodsScreenState extends State<CategoryFoodsScreen> {
  final NutritionController controller = Get.find<NutritionController>();

  List<FoodItem> foods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() {
      isLoading = true;
    });

    final items = await controller.searchFoodsByCategory(widget.category.categoryId);

    setState(() {
      foods = items;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.categoryName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      backgroundColor: bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : foods.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No foods found in this category', style: TextStyle(color: subText, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return _buildFoodCard(food, isDark);
        },
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey[600]!;
    final Color iconBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          final details = await controller.getFoodDetail(food.foodId);
          Get.back();
          if (details != null) _showFoodDetailsDialog(details);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    if (food.brandName.isNotEmpty) ...[
                      Text(
                        food.brandName,
                        style: TextStyle(fontSize: 14, color: subText, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (food.foodDescription.isNotEmpty)
                      Text(
                        food.foodDescription,
                        style: TextStyle(fontSize: 12, color: subText.withOpacity(0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: subText),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetailsDialog(FoodDetail details) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        details.foodName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: text),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text('Serving: ${details.servingSize}', style: TextStyle(color: subText)),
                      Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildNutritionRow('Calories', '${details.calories.toInt()}', 'kcal', Colors.red, text),
                      _buildNutritionRow('Protein', '${details.protein.toStringAsFixed(1)}', 'g', Colors.blue, text),
                      _buildNutritionRow('Carbs', '${details.carbs.toStringAsFixed(1)}', 'g', Colors.orange, text),
                      _buildNutritionRow('Fat', '${details.fat.toStringAsFixed(1)}', 'g', Colors.purple, text),
                      if (details.fiber > 0)
                        _buildNutritionRow('Fiber', '${details.fiber.toStringAsFixed(1)}', 'g', Colors.green, text),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _showSelectPlanDialog(details);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add to Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectPlanDialog(FoodDetail foodDetail) async {
    final controller = Get.find<NutritionController>();
    controller.fetchNutritionPlans();

    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.restaurant_menu, color: isDark ? Colors.green.shade200 : Colors.green.shade700, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Add to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  ),
                  IconButton(icon: Icon(Icons.close, color: text), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),

              // Food Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: subText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        foodDetail.foodName,
                        style: TextStyle(fontWeight: FontWeight.w500, color: text),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Plans List
              Obx(() {
                if (controller.nutritionPlans.isEmpty) {
                  return Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: subText),
                      const SizedBox(height: 12),
                      Text('No plans yet', style: TextStyle(fontSize: 16, color: subText)),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Get.back();
                          final result = await _showCreatePlanDialog(isDark);
                          if (result != null) {
                            await controller.addFoodToPlan(result.id, foodDetail, mealTime: 'Breakfast', servings: 1.0);
                            Get.snackbar('Added', '${foodDetail.foodName} added to ${result.description}', backgroundColor: Colors.green, colorText: Colors.white);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Plan'),
                      ),
                    ],
                  );
                }

                return Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...controller.nutritionPlans.map((plan) {
                          return Card(
                            color: cardBg,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.restaurant_menu, color: isDark ? Colors.green.shade200 : Colors.green.shade700, size: 20),
                              ),
                              title: Text(plan.description, style: TextStyle(fontWeight: FontWeight.w500, color: text)),
                              subtitle: Text('${plan.energy.toInt()} kcal', style: TextStyle(fontSize: 12, color: subText)),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
                              onTap: () async {
                                Get.back();
                                final mealTime = await _showMealSelectionDialog(isDark);
                                if (mealTime != null) {
                                  await controller.addFoodToPlan(plan.id, foodDetail, mealTime: mealTime, servings: 1.0);
                                  Get.snackbar('Added', '${foodDetail.foodName} added to $mealTime', backgroundColor: Colors.green, colorText: Colors.white);
                                }
                              },
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            Get.back();
                            final result = await _showCreatePlanDialog(isDark);
                            if (result != null) {
                              await controller.addFoodToPlan(result.id, foodDetail, mealTime: 'Breakfast', servings: 1.0);
                              Get.snackbar('Added', '${foodDetail.foodName} added to ${result.description}', backgroundColor: Colors.green, colorText: Colors.white);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Plan'),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showMealSelectionDialog(bool isDark) async {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    return await Get.dialog<String>(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 20),
              _buildMealOption('Breakfast', Icons.free_breakfast, Colors.orange, isDark),
              const SizedBox(height: 12),
              _buildMealOption('Lunch', Icons.lunch_dining, Colors.green, isDark),
              const SizedBox(height: 12),
              _buildMealOption('Dinner', Icons.dinner_dining, Colors.blue, isDark),
              const SizedBox(height: 12),
              _buildMealOption('Snack', Icons.cookie, Colors.purple, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealOption(String title, IconData icon, Color color, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      onTap: () => Get.back(result: title),
    );
  }

  Future<NutritionPlanModel?> _showCreatePlanDialog(bool isDark) async {
    final TextEditingController nameController = TextEditingController(text: 'My Nutrition Plan');
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return await Get.dialog<NutritionPlanModel>(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create New Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Plan Name',
                  labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                  hintText: 'e.g., Weight Loss',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final controller = Get.find<NutritionController>();
                        final plan = await controller.createNewPlan(description: name);
                        Get.back(result: plan);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Create', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: textColor))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(width: 3),
          Text(unit, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }
}
