import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/controller.dart';
// import 'path/to/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(ChangePasswordController());

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color inputBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final Color buttonColor = isDark ? Colors.white : Colors.black;
    final Color buttonTextColor = isDark ? Colors.black : Colors.white;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Change Password', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create a new password", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Your new password must be different from previous used passwords.", style: TextStyle(color: subText, fontSize: 14)),
              const SizedBox(height: 32),

              // Current Password
              _buildLabel("Current Password", textColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.currentPasswordController,
                bg: inputBg,
                textColor: textColor,
                obscure: controller.obscureCurrent.value,
                onToggle: controller.toggleCurrent,
                validator: (val) => val == null || val.isEmpty ? "Enter current password" : null,
              )),
              const SizedBox(height: 20),

              // New Password
              _buildLabel("New Password", textColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.newPasswordController,
                bg: inputBg,
                textColor: textColor,
                obscure: controller.obscureNew.value,
                onToggle: controller.toggleNew,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter new password";
                  if (val.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              )),
              const SizedBox(height: 20),

              // Confirm Password
              _buildLabel("Confirm Password", textColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.confirmPasswordController,
                bg: inputBg,
                textColor: textColor,
                obscure: controller.obscureConfirm.value,
                onToggle: controller.toggleConfirm,
                validator: (val) {
                  if (val != controller.newPasswordController.text) return "Passwords do not match";
                  return null;
                },
              )),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: buttonTextColor))
                      : Text("Update Password", style: TextStyle(color: buttonTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500));
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required Color bg,
    required Color textColor,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}