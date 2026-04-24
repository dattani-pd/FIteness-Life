import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/model.dart';

class NutritionPlanManager {
  static const String _plansKey = 'nutrition_plans';

  Future<void> savePlans(List<NutritionPlanModel> plans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = plans.map((plan) => plan.toJson()).toList();
      await prefs.setString(_plansKey, json.encode(plansJson));
      print('✅ Saved ${plans.length} plans to local storage');
    } catch (e) {
      print('❌ Error saving plans: $e');
    }
  }

  Future<List<NutritionPlanModel>> loadPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansString = prefs.getString(_plansKey);

      if (plansString == null || plansString.isEmpty) {
        print('ℹ️ No saved plans found');
        return [];
      }

      final List<dynamic> plansJson = json.decode(plansString);
      final plans = plansJson
          .map((json) => NutritionPlanModel.fromJson(json))
          .toList();

      print('✅ Loaded ${plans.length} plans from local storage');
      return plans;
    } catch (e) {
      print('❌ Error loading plans: $e');
      return [];
    }
  }

  Future<void> addPlan(NutritionPlanModel plan) async {
    final plans = await loadPlans();
    plans.add(plan);
    await savePlans(plans);
  }

  Future<void> deletePlan(String planId) async {
    final plans = await loadPlans();
    plans.removeWhere((plan) => plan.id == planId);
    await savePlans(plans);
  }

  Future<void> updatePlan(NutritionPlanModel updatedPlan) async {
    final plans = await loadPlans();
    final index = plans.indexWhere((plan) => plan.id == updatedPlan.id);
    if (index != -1) {
      plans[index] = updatedPlan;
      await savePlans(plans);
    }
  }

  Future<void> clearAllPlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_plansKey);
    print('✅ Cleared all plans');
  }
}
