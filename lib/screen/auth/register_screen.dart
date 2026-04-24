import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/register_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Status Bar control
import 'package:get/get.dart';
import '../../controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/register_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'register_controller.dart'; // તમારી ફાઈલ ઈમ્પોર્ટ કરો

class RegisterScreen extends GetView<RegisterController> {
  static const pageId = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME SETUP
    final bool isDark = Get.isDarkMode;
    final Color primaryRed = const Color(0xFF8B0000);

    // Dynamic Colors
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg, // ✅ Dynamic Background
        appBar: AppBar(
          backgroundColor: bg, // ✅ Dynamic AppBar
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor), // ✅ Dynamic Icon
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Join the Movement",
                  style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900), // ✅ Dynamic Text
                ),
                const SizedBox(height: 10),
                Text(
                  "Create your account to start training.",
                  style: TextStyle(color: subTextColor, fontSize: 16), // ✅ Dynamic Subtext
                ),
                const SizedBox(height: 40),

                // --- EMAIL FIELD ---
                TextField(
                  controller: controller.emailController,
                  style: TextStyle(color: textColor), // ✅ Text Color
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: subTextColor),
                    prefixIcon: Icon(Icons.email_outlined, color: subTextColor),
                    filled: true,
                    fillColor: inputFill, // ✅ Dark Fill

                    // DEFAULT BORDER
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5), // ✅ Dynamic Border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryRed, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- PASSWORD FIELD ---
                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  style: TextStyle(color: textColor), // ✅ Text Color
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: subTextColor),
                    prefixIcon: Icon(Icons.lock_outline, color: subTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: subTextColor,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    filled: true,
                    fillColor: inputFill, // ✅ Dark Fill

                    // DEFAULT BORDER
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5), // ✅ Dynamic Border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryRed, width: 2.0),
                    ),
                  ),
                )),
                const SizedBox(height: 25),

                // --- TRAINER SWITCH ---
                Container(
                  decoration: BoxDecoration(
                    color: inputFill, // ✅ Dark Fill
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5), // ✅ Dynamic Border
                  ),
                  child: Obx(() => SwitchListTile(
                    title: Text("I am a Trainer", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)), // ✅ Dynamic Text
                    subtitle: Text("Requires Admin approval", style: TextStyle(color: subTextColor, fontSize: 12)),
                    activeColor: primaryRed,
                    value: controller.isTrainer.value,
                    onChanged: (val) => controller.toggleRole(val),
                  )),
                ),

                const SizedBox(height: 40),

                // --- SIGN UP BUTTON ---
                SizedBox(
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: primaryRed.withOpacity(0.4),
                    ),
                    onPressed: controller.isLoading.value ? null : controller.registerUser,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: subTextColor)),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text("Login", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
