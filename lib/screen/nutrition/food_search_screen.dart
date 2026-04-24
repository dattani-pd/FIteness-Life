
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/controller.dart';
import '../../model/model.dart';
import '../screen.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nutrition_controller.dart';
import '../../model/model.dart';
import 'barcode_scanner_screen.dart'; // Ensure correct imports
import 'image_food_scanner_screen.dart'; // Ensure correct imports

// ==============================================================================
// FOOD SEARCH SCREEN (Themed)
// ==============================================================================

class FoodSearchScreen extends StatefulWidget {
  static const pageId = "/FoodSearchScreen";
  final String? initialQuery;

  const FoodSearchScreen({super.key, this.initialQuery});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final NutritionController controller = Get.isRegistered<NutritionController>()
      ? Get.find<NutritionController>()
      : Get.put(NutritionController());

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  var autocompleteSuggestions = <String>[].obs;
  var isLoadingSuggestions = false.obs;
  var showSuggestions = false.obs;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.searchFood(widget.initialQuery!);
        if (controller.searchResults.isNotEmpty) {
          final firstFood = controller.searchResults[0];
          FocusScope.of(Get.context!).unfocus();
          Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          final details = await controller.getFoodDetail(firstFood.foodId);
          Get.back();
          if (details != null) _showFoodDetailsDialog(details);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      autocompleteSuggestions.clear();
      showSuggestions.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      isLoadingSuggestions.value = true;
      showSuggestions.value = true;
      final suggestions = await controller.getAutocompleteSuggestions(query);
      autocompleteSuggestions.assignAll(suggestions);
      isLoadingSuggestions.value = false;
    });
  }

  void _selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    showSuggestions.value = false;
    searchFocus.unfocus();
    controller.searchFood(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color searchBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[200]!;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Search Foods", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: iconColor),
            tooltip: 'Scan Barcode',
            onPressed: () => Get.to(() => const BarcodeScannerScreen()),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: iconColor),
            tooltip: 'Scan Food Image',
            onPressed: () => Get.to(() => const ImageFoodScannerScreen()),
          ),
        ],
      ),
      backgroundColor: bg,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: searchBarBg,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  focusNode: searchFocus,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    hintStyle: TextStyle(color: hintColor),
                    prefixIcon: Icon(Icons.search, color: hintColor),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: hintColor),
                      onPressed: () {
                        searchController.clear();
                        controller.searchResults.clear();
                        autocompleteSuggestions.clear();
                        showSuggestions.value = false;
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) {
                    showSuggestions.value = false;
                    controller.searchFood(query);
                  },
                ),

                // Autocomplete Suggestions
                Obx(() {
                  if (!showSuggestions.value) return const SizedBox.shrink();

                  final Color suggestBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
                  final Color suggestText = isDark ? Colors.white : Colors.black;

                  if (isLoadingSuggestions.value) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: suggestBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }

                  if (autocompleteSuggestions.isEmpty) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: suggestBg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: autocompleteSuggestions.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final suggestion = autocompleteSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.search, size: 20, color: hintColor),
                          title: Text(suggestion, style: TextStyle(fontSize: 14, color: suggestText)),
                          trailing: Icon(Icons.north_west, size: 16, color: hintColor),
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) return const Center(child: CircularProgressIndicator());

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Search for any food', style: TextStyle(fontSize: 18, color: hintColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Try: chicken, apple, rice, etc.', style: TextStyle(fontSize: 14, color: hintColor)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final food = controller.searchResults[index];
                  return _buildFoodCard(food, isDark);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade500!;
    final Color iconBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          FocusScope.of(Get.context!).unfocus();
          await Future.delayed(const Duration(milliseconds: 100));
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
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.restaurant, color: isDark ? Colors.green.shade300 : Colors.green.shade700, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.foodName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    if (food.brandName.isNotEmpty) ...[
                      Text(food.brandName, style: TextStyle(fontSize: 14, color: subText, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                    ],
                    if (food.foodDescription.isNotEmpty)
                      Text(food.foodDescription, style: TextStyle(fontSize: 12, color: subText), maxLines: 2, overflow: TextOverflow.ellipsis),
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
    FocusScope.of(Get.context!).unfocus();
    final HomeController homeController = Get.find<HomeController>();
    final bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' || homeController.userRole.value == 'admin';

    // 🎨 Theme Logic
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(Get.context!).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(details.foodName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    IconButton(icon: Icon(Icons.close, color: text), onPressed: () => Get.back()),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Serving: ${details.servingSize}', style: TextStyle(fontSize: 13, color: subText)),
                      Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildNutritionRow('Calories', '${details.calories.toInt()}', 'kcal', Colors.red, text),
                      _buildNutritionRow('Protein', '${details.protein.toStringAsFixed(1)}', 'g', Colors.blue, text),
                      _buildNutritionRow('Carbs', '${details.carbs.toStringAsFixed(1)}', 'g', Colors.orange, text),
                      _buildNutritionRow('Fat', '${details.fat.toStringAsFixed(1)}', 'g', Colors.purple, text),
                    ],
                  ),
                ),
              ),
              if (isTrainerOrAdmin)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                          child: Text('Close', style: TextStyle(color: text)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back();
                            await _showSelectPlanDialog(details, isDark);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Add to Plan', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectPlanDialog(FoodDetail foodDetail, bool isDark) async {
    final controller = Get.find<NutritionController>();
    controller.fetchNutritionPlans();

    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.nutritionPlans.isEmpty) return Text('No plans found. Create one first.', style: TextStyle(color: subText));
                return Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: controller.nutritionPlans.map((plan) {
                        return ListTile(
                          title: Text(plan.description, style: TextStyle(color: text)),
                          subtitle: Text('${plan.energy.toInt()} kcal', style: TextStyle(color: subText)),
                          onTap: () async {
                            Get.back();
                            final mealTime = await _showMealSelectionDialog(isDark);
                            if (mealTime != null) {
                              await controller.addFoodToPlan(plan.id, foodDetail, mealTime: mealTime, servings: 1.0);
                              Get.snackbar("Success", "Food added to plan", backgroundColor: Colors.green, colorText: Colors.white);
                            }
                          },
                        );
                      }).toList(),
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
              ListTile(title: Text("Breakfast", style: TextStyle(color: text)), onTap: () => Get.back(result: "Breakfast")),
              ListTile(title: Text("Lunch", style: TextStyle(color: text)), onTap: () => Get.back(result: "Lunch")),
              ListTile(title: Text("Dinner", style: TextStyle(color: text)), onTap: () => Get.back(result: "Dinner")),
              ListTile(title: Text("Snack", style: TextStyle(color: text)), onTap: () => Get.back(result: "Snack")),
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
