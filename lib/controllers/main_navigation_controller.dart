
// ==========================================
// NAVIGATION CONTROLLER
// ==========================================

import 'package:get/get.dart';



class MainNavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ✅ Helper methods to navigate from anywhere
  void navigateToNutrition() => changePage(1);
  void navigateToWorkout() => changePage(2);
  void navigateToProfile() => changePage(3);
  void navigateToHome() => changePage(0);
}