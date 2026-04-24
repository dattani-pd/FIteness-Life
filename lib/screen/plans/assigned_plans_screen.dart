import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../../controllers/controller.dart';
import '../../model/model.dart';
import '../../model/nutrition_model.dart';
import '../screen.dart';

/// One plan entry for display (merged from workout_plan_assignments and user_purchases).
class _MergedPlan {
  final String planId;
  final String planName;
  final dynamic assignedAt;

  _MergedPlan({required this.planId, required this.planName, this.assignedAt});
}

class AssignedPlansScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String planType; // "workout" or "nutrition"

  const AssignedPlansScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.planType,
  });

  /// Builds a stream that merges:
  /// 1) workout_plan_assignments where assignedUsers contains userId
  /// 2) workout_plan_assignments where userId == userId
  /// 3) user_purchases/{userId}/plans (filtered by plan type)
  Stream<List<_MergedPlan>> _mergedPlansStream() {
    final collection = planType == 'workout'
        ? 'workout_plan_assignments'
        : 'nutrition_plan_assignments';
    final planCollection = planType == 'workout' ? 'workout_plans' : 'nutrition_plans';

    final streamByAssignedUsers = FirebaseFirestore.instance
        .collection(collection)
        .where('assignedUsers', arrayContains: userId)
        .snapshots();

    final streamByUserId = FirebaseFirestore.instance
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .snapshots();

    final streamPurchases = FirebaseFirestore.instance
        .collection('user_purchases')
        .doc(userId)
        .collection('plans')
        .snapshots();

    return rx.Rx.combineLatest3<QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        List<QuerySnapshot<Map<String, dynamic>>>>(
      streamByAssignedUsers,
      streamByUserId,
      streamPurchases,
      (a, b, c) => [a, b, c],
    ).asyncMap((snapshots) async {
      final snapAssign = snapshots[0];
      final snapByUser = snapshots[1];
      final snapPurchases = snapshots[2];
      final Map<String, _MergedPlan> byPlanId = {};

      void addFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final data = doc.data();
        final planId = (data['planId'] ?? doc.id).toString().trim();
        if (planId.isEmpty) return;
        final planName = data['planName']?.toString().trim() ?? data['planTitle']?.toString().trim() ?? 'Unnamed Plan';
        if (!byPlanId.containsKey(planId)) {
          byPlanId[planId] = _MergedPlan(
            planId: planId,
            planName: planName,
            assignedAt: data['assignedAt'],
          );
        }
      }

      for (final doc in snapAssign.docs) {
        addFromDoc(doc);
      }
      for (final doc in snapByUser.docs) {
        addFromDoc(doc);
      }

      // Resolve which purchase planIds belong to this plan type (workout or nutrition)
      final validPlanIds = <String>{};
      try {
        final planSnap = await FirebaseFirestore.instance.collection(planCollection).get();
        for (final doc in planSnap.docs) {
          validPlanIds.add(doc.id);
          final wooId = doc.data()['wooProductId']?.toString().trim();
          if (wooId != null && wooId.isNotEmpty) validPlanIds.add(wooId);
        }
      } catch (_) {}

      for (final doc in snapPurchases.docs) {
        final data = doc.data();
        final planId = (data['planId']?.toString().trim() ?? doc.id).toString().trim();
        if (planId.isEmpty) continue;
        if (!validPlanIds.contains(planId)) continue;
        if (byPlanId.containsKey(planId)) continue;
        final planName = data['planTitle']?.toString().trim() ?? data['planName']?.toString().trim() ?? 'Unnamed Plan';
        byPlanId[planId] = _MergedPlan(planId: planId, planName: planName, assignedAt: data['purchasedAt']);
      }

      return byPlanId.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    final title = planType == 'workout'
        ? "Workouts for $userName"
        : "Nutrition for $userName";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder<List<_MergedPlan>>(
        stream: _mergedPlansStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    "No ${planType} plans assigned yet.",
                    style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = plans[index];
              String? assignedOnText = _formatAssignedAt(plan.assignedAt);

              return Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (planType == 'workout' ? Colors.orange : Colors.green).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      planType == 'workout' ? Icons.fitness_center : Icons.restaurant,
                      color: planType == 'workout' ? Colors.orange : Colors.green,
                    ),
                  ),
                  title: Text(
                      plan.planName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)
                  ),
                  subtitle: assignedOnText != null
                      ? Text(
                          "Assigned on: $assignedOnText",
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54),
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                  onTap: () async {
                    if (plan.planId.isEmpty) {
                      Get.snackbar("Error", "Plan ID missing");
                      return;
                    }
                    if (planType == 'nutrition') {
                      _openNutritionPlan(plan.planId);
                    } else {
                      _openWorkoutPlan(plan.planId);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

// ==========================================
  // ✅ 1. OPEN NUTRITION PLAN (FIXED)
  // ==========================================
  void _openNutritionPlan(String planId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // 👇 1. Ensure the Controller is initialized
      if (!Get.isRegistered<NutritionController>()) {
        Get.put(NutritionController());
      }

      // 2. Fetch the plan (by doc id or wooProductId)
      var doc = await FirebaseFirestore.instance.collection('nutrition_plans').doc(planId).get();
      if (!doc.exists) {
        final byWoo = await FirebaseFirestore.instance
            .collection('nutrition_plans')
            .where('wooProductId', isEqualTo: planId)
            .limit(1)
            .get();
        if (byWoo.docs.isNotEmpty) {
          doc = byWoo.docs.first;
        }
      }

      if (Get.isDialogOpen ?? false) Get.back(); // Close loading

      if (doc.exists) {
        // Convert Firestore Data to NutritionPlanModel
        NutritionPlanModel plan = NutritionPlanModel.fromFirestore(doc.data()!, doc.id);

        // Open the screen you provided
        Get.to(() => PlanDetailScreen(
          plan: plan,
          isReadOnly: true, // Read Only for assigned view
        ));
      } else {
        Get.snackbar("Error", "This plan was deleted.");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Could not load plan: $e");
    }
  }

  // ==========================================
  // ✅ 2. OPEN WORKOUT PLAN
  // ==========================================
  void _openWorkoutPlan(String planId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      var doc = await FirebaseFirestore.instance.collection('workout_plans').doc(planId).get();
      if (!doc.exists) {
        final byWoo = await FirebaseFirestore.instance
            .collection('workout_plans')
            .where('wooProductId', isEqualTo: planId)
            .limit(1)
            .get();
        if (byWoo.docs.isNotEmpty) {
          doc = byWoo.docs.first;
        }
      }

      if (Get.isDialogOpen ?? false) Get.back(); // Close loading

      if (doc.exists) {
        WorkoutPlan workout = WorkoutPlan.fromFirestore(doc.data()!, doc.id);
        Get.to(() => WorkoutPlanDetailScreen(
          plan: workout,
          isReadOnly: true, // Read Only for assigned view
        ));
      } else {
        Get.snackbar("Error", "This workout plan was deleted.");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error opening workout plan: $e");
      Get.snackbar("Error", "Could not load workout.");
    }
  }

  /// Returns formatted date string if [assignedAt] is a valid Firestore Timestamp; null otherwise.
  /// Use null to hide the "Assigned on" line in the UI when date is missing.
  String? _formatAssignedAt(dynamic assignedAt) {
    if (assignedAt == null) return null;
    if (assignedAt is Timestamp) {
      try {
        final DateTime date = assignedAt.toDate();
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}