import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordController extends GetxController {
  // Text Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Observables (State)
  var isLoading = false.obs;
  var obscureCurrent = true.obs;
  var obscureNew = true.obs;
  var obscureConfirm = true.obs;

  // Toggle Visibility Methods
  void toggleCurrent() => obscureCurrent.value = !obscureCurrent.value;
  void toggleNew() => obscureNew.value = !obscureNew.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  // Main Logic
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "User not logged in", backgroundColor: Colors.red, colorText: Colors.white);
      isLoading.value = false;
      return;
    }

    try {
      // 1. Re-authenticate User (Required for sensitive actions)
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // 2. Update Password
      await user.updatePassword(newPasswordController.text.trim());

      // 3. Success
      isLoading.value = false;
      Get.back(); // Close screen
      Get.snackbar(
          "Success",
          "Password updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );

    } on FirebaseAuthException catch (e) {
      String message = "Failed to update password";
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "Current password is incorrect";
      } else if (e.code == 'weak-password') {
        message = "New password is too weak";
      }
      Get.snackbar("Error", message, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}