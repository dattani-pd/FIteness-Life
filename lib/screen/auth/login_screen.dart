import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  static const pageId = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS SETUP
    final bool isDark = Get.isDarkMode;
    final Color primaryRed = const Color(0xFF8B0000);

    // Backgrounds
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Text Colors
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final Color hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    // Borders
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg, // ✅ Dynamic Background
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // --- HEADER ---
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: inputFill,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: textColor, // ✅ Dynamic
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Sign in to continue your journey",
                    style: TextStyle(color: subTextColor, fontSize: 14), // ✅ Dynamic
                  ),
                ),

                const SizedBox(height: 40),

                // --- EMAIL FIELD ---
                TextField(
                  controller: controller.emailController,
                  style: TextStyle(color: textColor), // ✅ Text Color
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: hintColor),
                    prefixIcon: Icon(Icons.email_outlined, color: hintColor),
                    filled: true,
                    fillColor: inputFill, // ✅ Dark Background in Dark Mode

                    // DEFAULT BORDER
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5), // ✅ Dynamic Border
                    ),

                    // FOCUSED BORDER (RED)
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
                    labelStyle: TextStyle(color: hintColor),
                    prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                          controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                          color: hintColor
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    filled: true,
                    fillColor: inputFill, // ✅ Dynamic Fill

                    // DEFAULT BORDER
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5),
                    ),

                    // FOCUSED BORDER (RED)
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryRed, width: 2.0),
                    ),
                  ),
                )),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showForgotPasswordDialog(context, primaryRed, isDark);
                    },
                    child: Text("Forgot Password?", style: TextStyle(color: subTextColor)),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (v) => controller.rememberMe.value = v ?? true,
                        activeColor: primaryRed,
                        fillColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? primaryRed : null),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.rememberMe.value = !controller.rememberMe.value,
                      child: Text("Remember my email", style: TextStyle(color: subTextColor, fontSize: 14)),
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // --- LOGIN BUTTON ---
                SizedBox(
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: primaryRed.withOpacity(0.4),
                    ),
                    onPressed: controller.isLoading.value ? null : controller.login,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  )),
                ),

                const SizedBox(height: 30),

                // --- FOOTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: subTextColor)),
                    GestureDetector(
                      onTap: controller.goToRegister,
                      child: Text("Sign Up", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showForgotPasswordDialog(BuildContext context, Color primaryColor, bool isDark) {
    final resetEmailController = TextEditingController(text: controller.emailController.text);

    // Dialog Colors
    final Color dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    Get.defaultDialog(
      title: "Reset Password",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      backgroundColor: dialogBg, // ✅ Dark Dialog
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          Text(
            "Enter your email address and we will send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: resetEmailController,
            style: TextStyle(color: textColor), // ✅ Text Color
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(color: subTextColor),
              prefixIcon: Icon(Icons.email_outlined, color: subTextColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF121212) : Colors.white,
            ),
          ),
        ],
      ),
      confirm: SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            controller.resetPassword(resetEmailController.text);
          },
          child: const Text("Send", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: textColor)),
      ),
    );
  }
}
