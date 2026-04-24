import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/splash_controller.dart';
import 'screen.dart';

class SplashScreen extends StatefulWidget {
  static const pageId = "/SplashScreen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashController? _controller;

  @override
  void initState() {
    super.initState();

    // Ensure controller exists even if bindings fail on some devices.
    try {
      _controller = Get.find<SplashController>();
    } catch (_) {
      _controller = Get.put(SplashController());
    }

    // Safety net: if something prevents navigation, force it after a few seconds.
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (Get.currentRoute != SplashScreen.pageId) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.offAllNamed(LoginScreen.pageId);
      } else {
        Get.offAllNamed(MainNavigationScreen.pageId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    const primaryRed = Color(0xFF8B0000);
    final isDark = Get.isDarkMode;
    final bg = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF000000);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final logoBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = isDark ? Colors.black45 : Colors.grey.withOpacity(0.25);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // --- 1. LOGO (elastic scale-in) ---
                  AnimatedBuilder(
                    animation: controller.animController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: controller.scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: logoBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // --- 2. TITLE (slide up + fade in) ---
                  FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: SlideTransition(
                      position: controller.slideAnimation,
                      child: Column(
                        children: [
                        Text(
                          "FITNESS IS LIFE",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Train Hard. Live Better.",
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  ),

                  const SizedBox(height: 72),

                  // --- 3. LOADER (staggered fade-in) ---
                  AnimatedBuilder(
                    animation: controller.animController,
                    builder: (context, child) {
                      final loaderOpacity = controller.animController.value > 0.65
                          ? ((controller.animController.value - 0.65) / 0.35).clamp(0.0, 1.0)
                          : 0.0;
                      return Opacity(
                        opacity: loaderOpacity,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: primaryRed,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
