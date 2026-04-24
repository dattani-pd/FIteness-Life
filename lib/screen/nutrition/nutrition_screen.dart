// ==========================================
// 1. NUTRITION SCREEN
// ==========================================

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_life/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/nutrition_controller.dart';
import '../../model/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen.dart';


// ==========================================
// NUTRITION PLAN ASSIGNMENT FEATURE
class NutritionScreen extends StatelessWidget {
  static const pageId = "/NutritionScreen";
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NutritionController controller = Get.put(NutritionController());
    final HomeController homeController = Get.find<HomeController>();

    // ✅ UPDATED: Check if user is EITHER trainer OR admin
    final bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' ||
        homeController.userRole.value == 'admin';

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text("Nutrition Plans", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          // ✅ Search button for regular users in AppBar
          if (!isTrainerOrAdmin)
            IconButton(
              icon: Icon(Icons.search_rounded, color: iconColor),
              tooltip: 'Search Foods',
              onPressed: () => Get.to(() => const FoodSearchScreen()),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: iconColor),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchNutritionPlans(),
          ),
        ],
      ),
      backgroundColor: bg,
      body: Column(
        children: [
          // ✅ Info Banner for Regular Users ONLY
          if (!isTrainerOrAdmin)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are nutrition plans assigned to you by your trainer',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          /// Plans List

          // ✅ Quick Action Bar - Only for Trainers/Admins (Categories & Recipes)
          if (isTrainerOrAdmin)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ✅ Search
                  _buildQuickAction(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    color: Colors.green,
                    onTap: () => Get.to(() => const FoodSearchScreen()),
                    isDark: isDark,
                  ),
                  // ✅ Categories
                  _buildQuickAction(
                    icon: Icons.category_rounded,
                    label: 'Categories',
                    color: Colors.blue,
                    onTap: () => Get.to(() => const FoodCategoriesScreen()),
                    isDark: isDark,
                  ),
                  // ✅ Recipes
                  _buildQuickAction(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Recipes',
                    color: Colors.orange,
                    onTap: () => Get.to(() => const RecipeSearchScreen()),
                    isDark: isDark,
                  ),
                ],
              ),
            ),


          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.nutritionPlans.isEmpty) {
                return _buildEmptyState(isTrainerOrAdmin, isDark);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: controller.nutritionPlans.length,
                itemBuilder: (context, index) {
                  final plan = controller.nutritionPlans[index];
                  // ✅ Pass isTrainerOrAdmin flag
                  return _buildNutritionPlanCard(plan, isTrainerOrAdmin, controller, isDark);
                },
              );
            }),
          ),
        ],
      ),
      // ✅ FAB visible for trainers AND admins ONLY
      floatingActionButton: isTrainerOrAdmin
          ?  FloatingActionButton.extended(
        onPressed: () {
          _showCreatePlanDialog(context, controller, isDark);
        },
        backgroundColor: Colors.green.shade400,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Plan', style: TextStyle(color: Colors.white)),
      )
          :  null,
    );
  }

  // ✅ UPDATED: Renamed parameter to isTrainerOrAdmin and added isDark
  Widget _buildNutritionPlanCard(
      NutritionPlanModel plan,
      bool isTrainerOrAdmin,
      NutritionController controller,
      bool isDark,
      ) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => PlanDetailScreen(plan: plan, isReadOnly: !isTrainerOrAdmin,));
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade900, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(isDark ? 0.1 : 0.3), // Lighter shadow in dark mode
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.description.isEmpty ? "Unnamed Plan" : plan.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  plan.creationDate,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${plan.energy.toInt()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "kcal",
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
                ),

                // Macros
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroItem("Protein", "${plan.protein.toInt()}g", Colors.blue, isDark),
                      _buildMacroItem("Carbs", "${plan.carbs.toInt()}g", Colors.orange, isDark),
                      _buildMacroItem("Fat", "${plan.fat.toInt()}g", Colors.red, isDark),
                      _buildMacroItem("Fiber", "${plan.fiber.toInt()}g", Colors.green, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Three-dot menu for trainers AND admins
          if (isTrainerOrAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  _showPlanOptionsSheet(Get.context!, controller, plan, isDark);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Semi-transparent on gradient
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPlanOptionsSheet(
      BuildContext context,
      NutritionController controller,
      NutritionPlanModel plan,
      bool isDark,
      ) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                plan.description,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Assign to Users
            ListTile(
              leading: Icon(Icons.people, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
              title: Text(
                "Assign to Users",
                style: TextStyle(fontWeight: FontWeight.w500, color: text),
              ),
              subtitle: Text(
                "Choose which users can see this plan",
                style: TextStyle(fontSize: 12, color: subText),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () {
                Navigator.pop(ctx);
                _showUserSelectionSheet(context, controller, plan);
              },
            ),

            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Cancel
            ListTile(
              leading: Icon(Icons.close, color: subText),
              title: Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.w500, color: text),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showUserSelectionSheet(
      BuildContext context,
      NutritionController controller,
      NutritionPlanModel plan,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserPlanAssignmentContent(
        plan: plan,
        controller: controller,
      ),
    );
  }

  // Helper widgets
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? color.withOpacity(0.8) : color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ✅ Updated empty state with isTrainerOrAdmin parameter and theme
  Widget _buildEmptyState(bool isTrainerOrAdmin, bool isDark) {
    final Color iconColor = isDark ? Colors.green.shade700 : Colors.green.shade400;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isTrainerOrAdmin
                ? "No Nutrition Plans Yet"
                : "No Plans Assigned",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isTrainerOrAdmin
                ? "Create your first nutrition plan"
                : "Your trainer hasn't assigned any plans yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: subText,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context, NutritionController controller, bool isDark) {
    final TextEditingController nameController = TextEditingController(
      text: 'My Nutrition Plan',
    );
    // Don't redefine controller inside method since passed as arg
    // final controller = Get.find<NutritionController>();

    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[50]!;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
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
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: isDark ? Colors.red.shade200 : Colors.red.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create New Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: text),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Plan Name Input
              TextField(
                controller: nameController,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Plan Name',
                  labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.green),
                  hintText: 'e.g., Weight Loss Plan, Muscle Gain',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.edit_rounded, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: inputFill,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),

              // Info Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add foods and recipes to build your plan',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.blue.shade100 : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Cancel', style: TextStyle(color: text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter a plan name',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        Get.back();
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        final plan = await controller.createNewPlan(description: name);
                        Get.back();

                        Get.snackbar(
                          'Success',
                          'Plan "$name" created!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );

                        Get.to(() => PlanDetailScreen(plan: plan,   isReadOnly: false,));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Create Plan', style: TextStyle(color: Colors.white)),
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
}

class _UserPlanAssignmentContent extends StatefulWidget {
  final NutritionPlanModel plan;
  final NutritionController controller;

  const _UserPlanAssignmentContent({required this.plan, required this.controller});

  @override
  State<_UserPlanAssignmentContent> createState() => _UserPlanAssignmentContentState();
}

class _UserPlanAssignmentContentState extends State<_UserPlanAssignmentContent> {
  Map<String, bool> selectedUsers = {};
  List<Map<String, dynamic>> myStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentsAndAssignments();
  }

  Future<void> _loadStudentsAndAssignments() async {
    setState(() => isLoading = true);
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      var studentsSnapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').get();
      myStudents = studentsSnapshot.docs.map((doc) => {'uid': doc.id, 'name': doc.data()['name'] ?? 'Unknown', 'email': doc.data()['email'] ?? ''}).toList();

      final assignmentDoc = await FirebaseFirestore.instance.collection('nutrition_plan_assignments').doc(widget.plan.id).get();
      if (assignmentDoc.exists) {
        List assignedUsers = assignmentDoc.data()?['assignedUsers'] ?? [];
        for (var student in myStudents) {
          selectedUsers[student['uid']] = assignedUsers.contains(student['uid']);
        }
      } else {
        for (var student in myStudents) {
          selectedUsers[student['uid']] = false;
        }
      }
    } catch (e) {
      print('Error loading: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveAssignments() async {
    setState(() => isLoading = true);
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      List<String> assignedUserIds = selectedUsers.entries.where((e) => e.value).map((e) => e.key).toList();

      await FirebaseFirestore.instance.collection('nutrition_plan_assignments').doc(widget.plan.id).set({
        'planId': widget.plan.id,
        'planName': widget.plan.description,
        'assignedUsers': assignedUserIds,
        'assignedBy': currentUid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Saved', 'Assigned to ${assignedUserIds.length} users', backgroundColor: Colors.green, colorText: Colors.white);
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Theme Logic
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.80),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 50, height: 5, decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.people, color: isDark ? Colors.blue.shade200 : Colors.blue, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Assign Plan to Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                      const SizedBox(height: 4),
                      Text(widget.plan.description, style: TextStyle(fontSize: 13, color: subText), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.close, color: text), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          Flexible(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              shrinkWrap: true,
              itemCount: myStudents.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                var student = myStudents[index];
                bool isAssigned = selectedUsers[student['uid']] ?? false;
                return Card(
                  color: cardBg,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: dividerColor)),
                  child: CheckboxListTile(
                    value: isAssigned,
                    onChanged: (val) => setState(() => selectedUsers[student['uid']] = val ?? false),
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    title: Text(student['name'], style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: text)),
                    subtitle: Text(student['email'], style: TextStyle(fontSize: 12, color: subText)),
                    secondary: CircleAvatar(
                      backgroundColor: isAssigned ? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50) : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                      child: Icon(Icons.person_outline, color: isAssigned ? (isDark ? Colors.blue.shade200 : Colors.blue) : Colors.grey, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, color: text)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveAssignments,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// SUB-CATEGORY FOODS LIST SCREEN
// ==========================================

class SubCategoryFoodsScreen extends StatefulWidget {
  final FoodCategory category;
  final FoodSubCategory subCategory;

  const SubCategoryFoodsScreen({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<SubCategoryFoodsScreen> createState() => _SubCategoryFoodsScreenState();
}

class _SubCategoryFoodsScreenState extends State<SubCategoryFoodsScreen> {
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

    final items = await controller.searchFoodsBySubCategory(
        widget.subCategory.subCategoryId
    );

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
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subCategory.subCategoryName,
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            Text(
              widget.category.categoryName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: subText,
              ),
            ),
          ],
        ),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
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
            Text(
              'No foods found in this sub-category',
              style: TextStyle(color: subText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFoods,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
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
      elevation: isDark ? 1 : 2,
      child: InkWell(
        onTap: () async {
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          final details = await controller.getFoodDetail(food.foodId);
          Get.back();

          if (details != null) {
            _showFoodDetailsDialog(details, isDark);
          }
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (food.brandName.isNotEmpty) ...[
                      Text(
                        food.brandName,
                        style: TextStyle(
                          fontSize: 14,
                          color: subText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (food.foodDescription.isNotEmpty)
                      Text(
                        food.foodDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: subText.withOpacity(0.7),
                        ),
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

  void _showFoodDetailsDialog(FoodDetail details, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade800;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Added',
                        '${details.foodName} added to your plan',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
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

  Widget _buildNutritionRow(String label, String value, String unit, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 15, color: textColor)),
          ),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(width: 3),
          Text(unit, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }
}


// ==============================================================================
// RECIPE SEARCH SCREEN (Themed)
// ==============================================================================

class RecipeSearchScreen extends StatefulWidget {
  static const pageId = "/RecipeSearchScreen";
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  late final RecipeController controller;
  late final NutritionController nutritionController;
  final TextEditingController searchController = TextEditingController();

  List<RecipeType> recipeTypes = <RecipeType>[];
  bool isLoadingTypes = false;
  bool showTypes = true;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<RecipeController>()
        ? Get.find<RecipeController>()
        : Get.put(RecipeController());

    nutritionController = Get.find<NutritionController>();

    _loadRecipeTypes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipeTypes() async {
    if (!mounted) return;

    setState(() {
      isLoadingTypes = true;
    });

    try {
      final List<RecipeType> types = await nutritionController.getRecipeTypes();

      if (mounted) {
        setState(() {
          recipeTypes = types;
          isLoadingTypes = false;
        });
      }
    } catch (e) {
      print('❌ Error loading recipe types: $e');
      if (mounted) {
        setState(() {
          recipeTypes = <RecipeType>[];
          isLoadingTypes = false;
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
    final Color searchBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[200]!;
    final Color hintText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Search", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: searchBarBg,
            child: TextField(
              controller: searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search for recipes...',
                hintStyle: TextStyle(color: hintText),
                prefixIcon: Icon(Icons.restaurant_menu, color: hintText),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: hintText),
                  onPressed: () {
                    searchController.clear();
                    controller.searchResults.clear();
                    if (mounted) {
                      setState(() {
                        showTypes = true;
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: inputFill,
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  controller.searchRecipes(query);
                  if (mounted) {
                    setState(() {
                      showTypes = false;
                    });
                  }
                }
              },
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchResults.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final recipe = controller.searchResults[index];
                    return _buildRecipeCard(recipe, isDark);
                  },
                );
              }

              if (!showTypes && searchController.text.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No recipes found',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          searchController.clear();
                          if (mounted) {
                            setState(() {
                              showTypes = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.category, color: Colors.white),
                        label: const Text('Browse Categories', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildRecipeTypesGrid(isDark);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTypesGrid(bool isDark) {
    if (isLoadingTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipeTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No recipe types found', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRecipeTypes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.category, color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          ...recipeTypes.map((type) => _buildRecipeTypeCard(type, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecipeTypeCard(RecipeType type, bool isDark) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    int colorIndex = 0;
    try {
      colorIndex = int.parse(type.recipeTypeId) % colors.length;
    } catch (e) {
      colorIndex = type.recipeTypeId.hashCode.abs() % colors.length;
    }
    final color = colors[colorIndex];
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey[600]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          if (mounted) {
            setState(() {
              showTypes = false;
            });
          }

          try {
            final List<Recipe> recipes = await nutritionController.searchRecipesByType(type.recipeTypeId);
            controller.searchResults.assignAll(recipes);

            if (recipes.isEmpty) {
              Get.snackbar(
                'No Results',
                'No recipes found in this category',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );

              if (mounted) {
                setState(() {
                  showTypes = true;
                });
              }
            }
          } catch (e) {
            print('❌ Error loading recipes: $e');
            Get.snackbar(
              'Error',
              'Failed to load recipes',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );

            if (mounted) {
              setState(() {
                showTypes = true;
              });
            }
          }
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getRecipeTypeIcon(type.recipeTypeName),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.recipeTypeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (type.recipeTypeDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        type.recipeTypeDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: subText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

  // ✅ UPDATED: Recipe Card with Three-Dot Menu
  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey[700]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => RecipeDetailScreen(
                recipeId: recipe.recipeId,
                controller: controller,
              ));
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.recipeImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      recipe.recipeImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: isDark ? Colors.grey.shade800 : Colors.grey[300],
                          child: Icon(Icons.restaurant, size: 60, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.recipeName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (recipe.recipeDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          recipe.recipeDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: subText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (recipe.recipeTypes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: recipe.recipeTypes.take(3).map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.green.shade200 : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Three-dot menu (top-right corner)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                _showRecipeOptionsSheet(context, recipe, isDark);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Keep light for visibility on image
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Recipe Options Bottom Sheet
  void _showRecipeOptionsSheet(BuildContext context, Recipe recipe, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                recipe.recipeName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // View Details
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
              title: Text(
                "View Recipe Details",
                style: TextStyle(fontWeight: FontWeight.w500, color: text),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => RecipeDetailScreen(
                  recipeId: recipe.recipeId,
                  controller: controller,
                ));
              },
            ),

            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Add to Plan
            ListTile(
              leading: Icon(Icons.add_circle, color: Colors.green.shade700),
              title: Text(
                "Add to Nutrition Plan",
                style: TextStyle(fontWeight: FontWeight.w500, color: text),
              ),
              subtitle: Text(
                "Add this recipe to your plan",
                style: TextStyle(fontSize: 12, color: subText),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () async {
                Navigator.pop(ctx);

                // Load recipe details first
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                final recipeController = Get.find<RecipeController>();
                await recipeController.loadRecipeDetail(recipe.recipeId);

                Get.back(); // Close loading

                final recipeDetail = recipeController.selectedRecipe.value;
                if (recipeDetail != null) {
                  _showAddRecipeToPlanDialogFromSearch(recipeDetail, isDark);
                }
              },
            ),

            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Cancel
            ListTile(
              leading: Icon(Icons.close, color: subText),
              title: Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.w500, color: text),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Add Recipe to Plan Dialog
  Future<void> _showAddRecipeToPlanDialogFromSearch(RecipeDetail recipe, bool isDark) async {
    final nutritionController = Get.find<NutritionController>();
    nutritionController.fetchNutritionPlans();

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
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Header with Orange Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Add Recipe to Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 28, color: text),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Recipe Info Card with Orange Border
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.orange.shade900 : Colors.orange.shade200, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: isDark ? Colors.orange.shade200 : Colors.orange.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.recipeName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${recipe.nutrition.calories.toInt()} kcal per serving',
                            style: TextStyle(
                              fontSize: 14,
                              color: subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Plans List
              Flexible(
                child: Obx(() {
                  if (nutritionController.nutritionPlans.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: subText),
                        const SizedBox(height: 12),
                        Text(
                          'No plans yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: subText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a plan first',
                          style: TextStyle(
                            fontSize: 14,
                            color: subText,
                          ),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ...nutritionController.nutritionPlans.map((plan) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: isDark ? Colors.green.shade200 : Colors.green.shade700,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                plan.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: text,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${plan.energy.toInt()} kcal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subText,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: subText,
                              ),
                              onTap: () async {
                                Get.back();
                                final result = await _showMealAndServingsDialogSimple(isDark);
                                if (result != null) {
                                  await nutritionController.addRecipeToPlan(
                                    plan.id,
                                    recipe,
                                    mealTime: result['mealTime'],
                                    servings: result['servings'],
                                  );
                                  Get.snackbar(
                                    'Added',
                                    '${recipe.recipeName} added to ${result['mealTime']}',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    icon: const Icon(Icons.check_circle, color: Colors.white),
                                    duration: const Duration(seconds: 2),
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ✅ Create New Plan Button
              OutlinedButton.icon(
                onPressed: () async {
                  Get.back();
                  final result = await _showCreatePlanDialog(isDark);
                  if (result != null) {
                    await nutritionController.addRecipeToPlan(
                      result.id,
                      recipe,
                      mealTime: 'Breakfast',
                      servings: 1.0,
                    );
                    Get.snackbar(
                      'Added',
                      '${recipe.recipeName} added to ${result.description}',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Create New Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: BorderSide(color: Colors.teal.shade300, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<NutritionPlanModel?> _showCreatePlanDialog(bool isDark) async {
    final TextEditingController nameController = TextEditingController(
      text: 'My Nutrition Plan',
    );
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
              Text(
                'Create New Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Plan Name',
                  hintText: 'e.g., Weight Loss, Muscle Gain',
                  labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Cancel', style: TextStyle(color: text)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        final nutritionController = Get.find<NutritionController>();
                        final plan = await nutritionController.createNewPlan(description: name);

                        Get.back(result: plan);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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


  // ✅ Simplified meal selection
  Future<Map<String, dynamic>?> _showMealAndServingsDialogSimple(bool isDark) async {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    String? selectedMeal = await Get.dialog<String>(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Meal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text),
              ),
              const SizedBox(height: 24),
              _buildMealOptionCardSimple('Breakfast', Icons.free_breakfast, Colors.orange, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCardSimple('Lunch', Icons.lunch_dining, Colors.green, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCardSimple('Dinner', Icons.dinner_dining, Colors.blue, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCardSimple('Snack', Icons.cookie, Colors.purple, isDark),
            ],
          ),
        ),
      ),
    );

    if (selectedMeal == null) return null;

    return {
      'mealTime': selectedMeal,
      'servings': 1.0,
    };
  }

  Widget _buildMealOptionCardSimple(String mealName, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () => Get.back(result: mealName),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? color.withOpacity(0.8) : color, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              mealName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? color.withOpacity(0.9) : color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 18, color: isDark ? color.withOpacity(0.9) : color),
          ],
        ),
      ),
    );
  }

  IconData _getRecipeTypeIcon(String typeName) {
    final name = typeName.toLowerCase();
    if (name.contains('breakfast')) return Icons.free_breakfast;
    if (name.contains('lunch')) return Icons.lunch_dining;
    if (name.contains('dinner')) return Icons.dinner_dining;
    if (name.contains('dessert')) return Icons.cake;
    if (name.contains('snack')) return Icons.cookie;
    if (name.contains('appetizer')) return Icons.tapas;
    if (name.contains('main')) return Icons.restaurant;
    if (name.contains('side')) return Icons.rice_bowl;
    if (name.contains('beverage') || name.contains('drink')) return Icons.local_cafe;
    if (name.contains('vegetarian')) return Icons.eco;
    if (name.contains('vegan')) return Icons.spa;
    if (name.contains('salad')) return Icons.set_meal;
    if (name.contains('soup')) return Icons.soup_kitchen;
    return Icons.restaurant_menu;
  }
}

// ==========================================
// RECIPE DETAIL SCREEN
// ==========================================

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final RecipeController? controller;
  final bool isReadOnly;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use passed controller or find/create one
    final RecipeController recipeController = controller ??
        (Get.isRegistered<RecipeController>()
            ? Get.find<RecipeController>()
            : Get.put(RecipeController()));

    recipeController.loadRecipeDetail(recipeId);

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      body: Obx(() {
        if (recipeController.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipe = recipeController.selectedRecipe.value;
        if (recipe == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: iconColor),
                const SizedBox(height: 16),
                Text('Recipe not found', style: TextStyle(color: textColor)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              foregroundColor: textColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  recipe.recipeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black45),
                    ],
                  ),
                ),
                background: recipe.recipeImage.isNotEmpty
                    ? Image.network(
                  recipe.recipeImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Icon(Icons.restaurant, size: 80, color: iconColor),
                    );
                  },
                )
                    : Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: Icon(Icons.restaurant, size: 80, color: iconColor),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Info Card
                  _buildInfoCard(recipe, cardBg, textColor, subText, isDark),

                  // ✅ ADD RECIPE TO PLAN BUTTON
                  if (!isReadOnly)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _showAddRecipeToPlanDialog(recipe);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                          label: const Text(
                            'Add Recipe to Nutrition Plan',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),

                  // Nutrition Card
                  _buildNutritionCard(recipe, cardBg, textColor, subText),

                  // Ingredients
                  _buildIngredientsSection(recipe, cardBg, textColor),

                  // Directions
                  _buildDirectionsSection(recipe, cardBg, textColor),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ... Widgets ...

  Widget _buildInfoCard(RecipeDetail recipe, Color cardBg, Color textColor, Color subText, bool isDark) {
    return Card(
      color: cardBg,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.recipeDescription.isNotEmpty) ...[
              Text(
                recipe.recipeDescription,
                style: TextStyle(fontSize: 15, color: subText),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                if (recipe.preparationTime.isNotEmpty)
                  _buildInfoItem(Icons.schedule, 'Prep', recipe.preparationTime, textColor, subText),
                if (recipe.cookingTime.isNotEmpty) ...[
                  const SizedBox(width: 20),
                  _buildInfoItem(Icons.timer, 'Cook', recipe.cookingTime, textColor, subText),
                ],
                const SizedBox(width: 20),
                _buildInfoItem(Icons.people, 'Servings', '${recipe.numberOfServings}', textColor, subText),
              ],
            ),
            if (recipe.recipeTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipe.recipeTypes.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.green.shade200 : Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color textColor, Color subText) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade700),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: subText)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionCard(RecipeDetail recipe, Color cardBg, Color textColor, Color subText) {
    final nutrition = recipe.nutrition;
    return Card(
      color: cardBg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition (per serving)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientItem('Calories', '${nutrition.calories.toInt()}', 'kcal', Colors.red, subText),
                _buildNutrientItem('Protein', '${nutrition.protein.toInt()}', 'g', Colors.blue, subText),
                _buildNutrientItem('Carbs', '${nutrition.carbs.toInt()}', 'g', Colors.orange, subText),
                _buildNutrientItem('Fat', '${nutrition.fat.toInt()}', 'g', Colors.purple, subText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String label, String value, String unit, Color color, Color subText) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: TextStyle(fontSize: 12, color: subText)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: subText)),
      ],
    );
  }

  Widget _buildIngredientsSection(RecipeDetail recipe, Color cardBg, Color textColor) {
    if (recipe.ingredients.isEmpty) return const SizedBox.shrink();

    return Card(
      color: cardBg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            ...recipe.ingredients.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: Colors.green.shade700, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(ingredient.ingredientDescription, style: TextStyle(fontSize: 15, color: textColor)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionsSection(RecipeDetail recipe, Color cardBg, Color textColor) {
    if (recipe.directions.isEmpty) return const SizedBox.shrink();

    return Card(
      color: cardBg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            ...recipe.directions.map((direction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Colors.green.shade700, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${direction.directionNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(direction.directionDescription, style: TextStyle(fontSize: 15, height: 1.5, color: textColor)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ✅ THEMED Add Recipe Dialog
  Future<void> _showAddRecipeToPlanDialog(RecipeDetail recipe) async {
    final nutritionController = Get.find<NutritionController>();
    nutritionController.fetchNutritionPlans();

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
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.restaurant_menu, color: isDark ? Colors.orange.shade200 : Colors.orange.shade700, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Add Recipe to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  ),
                  IconButton(icon: Icon(Icons.close, color: text), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),

              // Recipe Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.orange.shade900 : Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: isDark ? Colors.orange.shade200 : Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.recipeName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: text), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('${recipe.nutrition.calories.toInt()} kcal per serving', style: TextStyle(fontSize: 12, color: subText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Plans List
              Flexible(
                child: Obx(() {
                  if (nutritionController.nutritionPlans.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: subText),
                        const SizedBox(height: 12),
                        Text('No plans yet', style: TextStyle(fontSize: 16, color: subText)),
                        const SizedBox(height: 8),
                        Text('Create a plan first', style: TextStyle(fontSize: 14, color: subText)),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () async {
                            Get.back();
                            // Call existing create dialog (ensure that function is accessible or recreated)
                            // For now assuming user knows where to create
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Plan'),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ...nutritionController.nutritionPlans.map((plan) {
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
                                final result = await _showMealAndServingsDialog(isDark);

                                if (result != null) {
                                  await nutritionController.addRecipeToPlan(
                                    plan.id,
                                    recipe,
                                    mealTime: result['mealTime'],
                                    servings: result['servings'],
                                  );

                                  Get.snackbar(
                                    'Added',
                                    '${recipe.recipeName} added to ${result['mealTime']}',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    icon: const Icon(Icons.check_circle, color: Colors.white),
                                    duration: const Duration(seconds: 2),
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ THEMED Meal Selection Dialog
  Future<Map<String, dynamic>?> _showMealAndServingsDialog(bool isDark) async {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    String? selectedMeal = await Get.dialog<String>(
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
              _buildMealOptionCard('Breakfast', Icons.free_breakfast, Colors.orange, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCard('Lunch', Icons.lunch_dining, Colors.green, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCard('Dinner', Icons.dinner_dining, Colors.blue, isDark),
              const SizedBox(height: 12),
              _buildMealOptionCard('Snack', Icons.cookie, Colors.purple, isDark),
            ],
          ),
        ),
      ),
    );

    if (selectedMeal == null) return null;

    double? servings = await _showServingsDialog(isDark);
    if (servings == null) return null;

    return {'mealTime': selectedMeal, 'servings': servings};
  }

  Widget _buildMealOptionCard(String mealName, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () => Get.back(result: mealName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? color.withOpacity(0.9) : color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(mealName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? color.withOpacity(0.9) : color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? color.withOpacity(0.9) : color),
          ],
        ),
      ),
    );
  }

  // ✅ THEMED Servings Dialog
  Future<double?> _showServingsDialog(bool isDark) async {
    double servings = 1.0;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return await Get.dialog<double>(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Number of Servings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (servings > 0.5) setState(() => servings -= 0.5);
                        },
                        icon: const Icon(Icons.remove_circle_outline, size: 40),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: Text(servings.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: text)),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () => setState(() => servings += 0.5),
                        icon: const Icon(Icons.add_circle_outline, size: 40),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: Text('Cancel', style: TextStyle(color: text)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(result: servings),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


// ==============================================================================
// LOCAL RECIPE DETAIL SCREEN (Themed)
// ==============================================================================

class LocalRecipeDetailScreen extends StatefulWidget {
  final MealItem mealItem;
  final String planId;
  final String mealTime;
  final bool isReadOnly;

  const LocalRecipeDetailScreen({
    super.key,
    required this.mealItem,
    required this.planId,
    required this.mealTime,
    required this.isReadOnly,
  });

  @override
  State<LocalRecipeDetailScreen> createState() => _LocalRecipeDetailScreenState();
}

class _LocalRecipeDetailScreenState extends State<LocalRecipeDetailScreen> {
  late TextEditingController _descController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _directionControllers;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.mealItem.description ?? '');

    _ingredientControllers = (widget.mealItem.ingredients ?? [])
        .map((i) => TextEditingController(text: i))
        .toList();

    _directionControllers = (widget.mealItem.directions ?? [])
        .map((d) => TextEditingController(text: d))
        .toList();
  }

  @override
  void dispose() {
    _descController.dispose();
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _directionControllers) c.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final controller = Get.find<NutritionController>();

    // Create updated MealItem
    final updatedItem = MealItem(
      name: widget.mealItem.name,
      amount: widget.mealItem.amount,
      calories: widget.mealItem.calories,
      protein: widget.mealItem.protein,
      carbs: widget.mealItem.carbs,
      fat: widget.mealItem.fat,
      isRecipe: true,
      recipeId: widget.mealItem.recipeId,
      image: widget.mealItem.image,
      description: _descController.text,
      ingredients: _ingredientControllers.map((c) => c.text).toList(),
      directions: _directionControllers.map((c) => c.text).toList(),
    );

    // Call update method in controller
    await controller.updateMealItemInPlan(
        widget.planId,
        widget.mealTime,
        widget.mealItem, // Old Item to find
        updatedItem      // New Item to replace
    );

    setState(() {
      _isEditing = false;
    });

    Get.snackbar("Success", "Recipe updated successfully", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[100]!;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.mealItem.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit, color: iconColor),
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (widget.mealItem.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.mealItem.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    child: Icon(Icons.restaurant, size: 50, color: subText),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Description
            Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            _isEditing
                ? TextField(
              controller: _descController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            )
                : Text(
              widget.mealItem.description ?? "No description available",
              style: TextStyle(color: subText, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Ingredients
            Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            ..._buildEditableList(_ingredientControllers, textColor, inputFill),

            const SizedBox(height: 24),

            // Directions
            Text("Directions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            ..._buildEditableList(_directionControllers, textColor, inputFill),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEditableList(List<TextEditingController> controllers, Color textColor, Color inputFill) {
    if (controllers.isEmpty) {
      return [Text("No information provided", style: TextStyle(color: textColor.withOpacity(0.6), fontStyle: FontStyle.italic))];
    }

    return controllers.map((c) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, right: 12.0),
              child: Icon(Icons.circle, size: 8, color: Colors.green),
            ),
            Expanded(
              child: _isEditing
                  ? TextField(
                controller: c,
                maxLines: null,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.only(top: 2), // Align with bullet
                child: Text(
                  c.text,
                  style: TextStyle(fontSize: 15, color: textColor, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
