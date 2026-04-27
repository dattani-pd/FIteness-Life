import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  static const pageId = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = const Color(0xFF8B0000);
    final Color bg = Colors.white; // ✅ Force white for iOS fix
    final Color inputFill = Colors.white;

    final Color textColor = Colors.black;
    final Color subTextColor = Colors.grey;
    final Color hintColor = Colors.grey.shade600;
    final Color borderColor = Colors.grey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // ✅ FIX
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg, // ✅ FIX
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

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
                              color: Colors.black.withOpacity(0.1),
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
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Sign in to continue your journey",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- EMAIL ---
                    TextField(
                      controller: controller.emailController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: hintColor),
                        prefixIcon: Icon(Icons.email_outlined, color: hintColor),
                        filled: true,
                        fillColor: inputFill,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryRed, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- PASSWORD ---
                    Obx(
                          () => TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: hintColor),
                          prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: hintColor,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          filled: true,
                          fillColor: inputFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryRed, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showForgotPasswordDialog(context, primaryRed);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Obx(
                          () => Row(
                        children: [
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (v) =>
                            controller.rememberMe.value = v ?? true,
                            activeColor: primaryRed,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.rememberMe.value =
                            !controller.rememberMe.value,
                            child: Text(
                              "Remember my email",
                              style: TextStyle(color: subTextColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- LOGIN BUTTON ---
                    SizedBox(
                      height: 55,
                      child: Obx(
                            () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- FOOTER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: subTextColor),
                        ),
                        GestureDetector(
                          onTap: controller.goToRegister,
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showForgotPasswordDialog(BuildContext context, Color primaryColor) {
    final resetEmailController = TextEditingController();

    Get.defaultDialog(
      title: "Reset Password",
      content: Column(
        children: [
          const Text("Enter your email to reset password"),
          const SizedBox(height: 20),
          TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          controller.resetPassword(resetEmailController.text);
          Get.back();
        },
        child: const Text("Send"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }
}
