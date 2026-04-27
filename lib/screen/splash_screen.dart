import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

      final user = Firebase.apps.isNotEmpty
          ? FirebaseAuth.instance.currentUser
          : null;
      if (user == null) {
        Get.offAllNamed(LoginScreen.pageId);
      } else {
        Get.offAllNamed(MainNavigationScreen.pageId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: const SizedBox.expand(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: Image(
                      image: AssetImage('assets/images/app_logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF8B0000),
                      strokeWidth: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
