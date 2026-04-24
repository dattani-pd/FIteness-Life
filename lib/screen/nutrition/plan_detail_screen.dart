import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller.dart';
import '../../model/model.dart';
import '../screen.dart';


// ==============================================================================
// PLAN DETAIL SCREEN (Themed)
// ==============================================================================

class PlanDetailScreen extends StatelessWidget {
  final NutritionPlanModel plan; // Initial plan data (for ID)
  final bool isReadOnly;

  const PlanDetailScreen({
    super.key,
    required this.plan,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NutritionController>();

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        // ✅ TITLE UPDATES AUTOMATICALLY
        title: Obx(() {
          final livePlan = controller.nutritionPlans
              .firstWhere((p) => p.id == plan.id, orElse: () => plan);
          return Text(livePlan.description, style: TextStyle(color: textColor));
        }),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (!isReadOnly) ...[
            IconButton(
              icon: Icon(Icons.edit, color: iconColor),
              onPressed: () => _showEditNameDialog(context, controller, plan.id, plan.description, isDark),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmDialog(context, controller, plan.id, plan.description, isDark),
            ),
          ],
        ],
      ),
      backgroundColor: bg,

      // ✅ WRAP BODY IN OBX TO LISTEN FOR UPDATES
      body: Obx(() {
        // 1. Find the latest version of this plan from the controller
        final livePlan = controller.nutritionPlans
            .firstWhere((p) => p.id == plan.id, orElse: () => plan);

        return SingleChildScrollView(
          child: Column(
            children: [
              if (isReadOnly)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This plan is assigned by your trainer. You cannot edit it.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ✅ PASS LIVE DATA TO WIDGETS
              _buildSummaryCard(livePlan, isDark),

              _buildMealsSection(context, controller, livePlan, isDark),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isReadOnly
          ? null
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
            // 🟠 1. NEW: Add Recipe Button
            FloatingActionButton.extended(
              heroTag: "btnRecipe",
              onPressed: () {
                Get.to(() => const RecipeSearchScreen());
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Recipe', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 12),

            // 🟢 2. EXISTING: Add Food Button
            FloatingActionButton.extended(
              heroTag: "btnFood",
              onPressed: () {
                Get.to(() => const FoodSearchScreen());
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Food', style: TextStyle(color: Colors.white)),
            ),
                    ],
                  ),
          ),
    );
  }

  // ✅ UPDATED: Accepts 'currentPlan' and 'isDark'
  Widget _buildSummaryCard(NutritionPlanModel currentPlan, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentPlan.energy.toInt()} kcal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Daily Calories',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', currentPlan.protein, 'g', Colors.blue.shade200),
              _buildMacroItem('Carbs', currentPlan.carbs, 'g', Colors.orange.shade200),
              _buildMacroItem('Fat', currentPlan.fat, 'g', Colors.red.shade200),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${value.toInt()}$unit',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ✅ UPDATED: Accepts 'currentPlan' and 'isDark'
  Widget _buildMealsSection(BuildContext context, NutritionController controller, NutritionPlanModel currentPlan, bool isDark) {
    final Color emptyCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (currentPlan.meals.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: emptyCardBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(Icons.no_meals, size: 60, color: subText),
            const SizedBox(height: 16),
            Text(
              'No meals added yet',
              style: TextStyle(
                fontSize: 16,
                color: subText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isReadOnly) ...[
              const SizedBox(height: 8),
              Text(
                'Tap the + button below to add foods',
                style: TextStyle(fontSize: 14, color: subText.withOpacity(0.7)),
              ),
            ],
          ],
        ),
      );
    }

    // Iterate over the LIVE plan's meals
    return Column(
      children: currentPlan.meals.map((meal) {
        return _buildMealCard(context, meal, controller, currentPlan, isDark);
      }).toList(),
    );
  }

  // ✅ UPDATED: Accepts 'currentPlan' and 'isDark'
  Widget _buildMealCard(BuildContext context, Meal meal, NutritionController controller, NutritionPlanModel currentPlan, bool isDark) {
    double mealCalories = 0;
    for (var item in meal.items) {
      mealCalories += item.calories;
    }

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headerBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;
    final Color headerText = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color itemText = isDark ? Colors.white : Colors.black87;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getMealIcon(meal.time),
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headerText,
                        ),
                      ),
                      Text(
                        '${mealCalories.toInt()} kcal • ${meal.items.length} items',
                        style: TextStyle(
                          fontSize: 13,
                          color: subText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isReadOnly)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: () {
                      _showDeleteMealDialog(context, controller, currentPlan.id, meal.time, isDark);
                    },
                  ),
              ],
            ),
          ),
          ...meal.items.map((item) {
            final Color itemBg = item.isRecipe
                ? (isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50)
                : (isDark ? Colors.grey.shade800 : Colors.grey[100]!);

            final Color itemIconColor = item.isRecipe
                ? (isDark ? Colors.orange.shade300 : Colors.orange.shade700)
                : (isDark ? Colors.grey.shade400 : Colors.grey[700]!);

            return ListTile(
              onTap: (item.isRecipe)
                  ? () {
                Get.to(() => LocalRecipeDetailScreen(
                  mealItem: item,
                  planId: currentPlan.id,
                  mealTime: meal.time,
                  isReadOnly: isReadOnly,
                ));
              }
                  : null,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: itemBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.isRecipe ? Icons.restaurant_menu : Icons.restaurant,
                  size: 20,
                  color: itemIconColor,
                ),
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: item.isRecipe ? (isDark ? Colors.orange.shade200 : Colors.orange.shade900) : itemText,
                ),
              ),
              subtitle: Text(
                '${item.calories.toInt()} kcal • P: ${item.protein.toInt()}g',
                style: TextStyle(fontSize: 12, color: subText),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.amount}x',
                    style: TextStyle(
                      fontSize: 14,
                      color: subText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.isRecipe && item.recipeId != null)
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () {
                        Get.to(() => LocalRecipeDetailScreen(
                          mealItem: item,
                          planId: currentPlan.id,
                          mealTime: meal.time,
                          isReadOnly: true,
                        ));
                      },
                    ),
                  if (!isReadOnly)
                    PopupMenuButton(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      icon: Icon(Icons.more_vert, size: 20, color: subText),
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text('Edit Quantity', style: TextStyle(color: itemText)),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showEditQuantityDialog(
                                  context,
                                  controller,
                                  currentPlan.id,
                                  meal.time,
                                  item,
                                  isDark
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Remove', style: TextStyle(color: itemText)),
                            ],
                          ),
                          onTap: () async {
                            await controller.removeFoodItemFromPlan(
                              currentPlan.id,
                              meal.time,
                              item.name,
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- DIALOGS (Themed) ---

  void _showDeleteMealDialog(
      BuildContext context,
      NutritionController controller,
      String planId,
      String mealTime,
      bool isDark,
      ) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever_rounded, size: 60, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Delete $mealTime?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text),
              ),
              const SizedBox(height: 12),
              Text(
                'This will remove all foods and recipes from this meal section.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subText),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300)),
                      child: Text('Cancel', style: TextStyle(color: text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.deleteEntireMeal(planId, mealTime);
                        Get.snackbar('Deleted', '$mealTime has been cleared', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
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

  void _showDeleteConfirmDialog(
      BuildContext context, NutritionController controller, String planId, String planName, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange[700]),
              const SizedBox(height: 16),
              Text('Delete Plan?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 12),
              Text('Permanently delete "$planName"?', textAlign: TextAlign.center, style: TextStyle(color: subText)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300)),
                      child: Text('Cancel', style: TextStyle(color: text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        Get.back(); // Go back to list
                        await controller.deletePlan(planId);
                        Get.snackbar('Deleted', 'Plan deleted successfully', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
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

  void _showEditNameDialog(BuildContext context, NutritionController controller, String planId, String currentName, bool isDark) {
    final textController = TextEditingController(text: currentName);
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Plan Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Plan Name',
                  labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                  filled: true,
                  fillColor: inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300)),
                      child: Text('Cancel', style: TextStyle(color: text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = textController.text.trim();
                        if (newName.isNotEmpty) {
                          await controller.updatePlanDescription(planId, newName);
                          Get.back();
                          Get.snackbar('Updated', 'Plan name updated', backgroundColor: Colors.green, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
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

  void _showEditQuantityDialog(BuildContext context, NutritionController controller, String planId, String mealTime, MealItem item, bool isDark) {
    final quantityController = TextEditingController(text: item.amount.toString());
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    Get.dialog(
      AlertDialog(
        backgroundColor: bg,
        title: Text('Edit Quantity', style: TextStyle(color: text)),
        content: TextField(
          controller: quantityController,
          style: TextStyle(color: text),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: '1.0',
            labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
            filled: true,
            fillColor: inputFill,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newQty = double.tryParse(quantityController.text);
              if (newQty != null && newQty > 0) {
                Get.back();
                await controller.updateFoodItemQuantity(planId, mealTime, item.name, newQty);
                Get.snackbar('Updated', 'Quantity changed', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealTime) {
    switch (mealTime.toLowerCase()) {
      case 'breakfast': return Icons.free_breakfast_rounded;
      case 'lunch': return Icons.lunch_dining_rounded;
      case 'dinner': return Icons.dinner_dining_rounded;
      case 'snack': return Icons.cookie_rounded;
      default: return Icons.restaurant_rounded;
    }
  }
}
