import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_life/screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/constant.dart';
import '../utils/shared_preferences_helper.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = true.obs;

  static const String _rememberedEmailKey = 'remembered_login_email';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    try {
      final email = await sharedPreferencesHelper.getPrefData(_rememberedEmailKey);
      if (isClosed) return;
      if (email != null && email.isNotEmpty) {
        emailController.text = email;
      }
    } catch (_) {}
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void goToRegister() {
    Get.toNamed(RegisterScreen.pageId);
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Authenticate with Firebase Auth
      print('[Login] Attempting sign in for: ${emailController.text.trim()}');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        print('[Login] Auth success. UID: $uid');

        // 2. Fetch User Data from Firestore
        DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          isLoading.value = false;
          await _auth.signOut();
          print('[Login] Auth success but Firestore doc not found for uid: $uid');
          Get.snackbar("Login Failed", "Account data not found. Please contact support.", backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        final data = userDoc.data() as Map<String, dynamic>? ?? {};
        String role = (data['role']?.toString() ?? 'user').trim().toLowerCase();
        if (role.isEmpty) role = 'user';
        String email = (data['email']?.toString() ?? '').trim();
        bool isApproved = data['isApproved'] == true || data['isApproved'] == "true";
        bool isPlaceholder = data['isPlaceholder'] == true || data['isPlaceholder'] == "true";
        String name = (data['name'] ?? data['displayName'] ?? '').toString().trim();

        print('[Login] Firestore doc found. role=$role, isApproved=$isApproved, isPlaceholder=$isPlaceholder');

        // Placeholder: user record exists but is not yet a full account (e.g. from WooCommerce). Must register first.
        if (isPlaceholder) {
          isLoading.value = false;
          await _auth.signOut();
          print('[Login] User is placeholder. Must register first.');
          Get.snackbar("Registration Required", "Please Register first to create your account.", backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 4));
          return;
        }

        // Not approved: show specific message and still allow entry (Home will show pending UI)
        if (!isApproved) {
          print('[Login] User not approved. Showing pending message and navigating to Home.');
          Get.snackbar("Pending Approval", "Your account is pending admin approval.", backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 3));
        }

        // 3. Save to Local Storage (Crucial for Home Screen)
        await AppConstants.setUserId(uid);
        await AppConstants.setEmail(email);
        await AppConstants.setRole(role);
        await AppConstants.setApproved(isApproved);
        if (name.isNotEmpty) await AppConstants.setUserName(name);

        isLoading.value = false;

        // Remember email for next time if "Remember me" is checked
        if (rememberMe.value) {
          await sharedPreferencesHelper.storePrefData(_rememberedEmailKey, emailController.text.trim());
        } else {
          await sharedPreferencesHelper.clearPrefDataByKey(_rememberedEmailKey);
        }

        // 4. UNIFIED ROUTING LOGIC
        print('[Login] Success. Navigating to Home. role=$role, isApproved=$isApproved');
        Get.offAllNamed(MainNavigationScreen.pageId);
      } else {
        isLoading.value = false;
        print('[Login] Auth returned null user.');
      }
    } catch (e) {
      isLoading.value = false;

      String title = "Login Failed";
      String message = "Invalid Credentials";

      if (e is FirebaseAuthException) {
        print('[Login] FirebaseAuthException: code=${e.code}, message=${e.message}');
        switch (e.code) {
          case 'user-not-found':
          case 'user-disabled':
            title = "Account Not Found";
            message = "No account found for this email. Please sign up or check your email.";
            break;
          case 'wrong-password':
          case 'invalid-credential':
            title = "Wrong Password";
            message = "The password is incorrect. Please try again or use Forgot Password.";
            break;
          case 'invalid-email':
            message = "Please enter a valid email address.";
            break;
          case 'too-many-requests':
            title = "Too Many Attempts";
            message = "Please wait a few minutes before trying again.";
            break;
          default:
            message = e.message ?? "Please check your email and password and try again.";
        }
      } else {
        print('[Login] Unexpected error: $e');
      }

      Get.snackbar(title, message, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
          "Error",
          "Please enter a valid email address",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      return;
    }

    try {
      // Show loading indicator usually, but for a dialog action, we can just await
      await _auth.sendPasswordResetEmail(email: email.trim());

      Get.back(); // Close the dialog
      Get.snackbar(
        "Email Sent",
        "Check your inbox to reset your password.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      String errorMessage = "An error occurred";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found with this email.";
      } else if (e.toString().contains("invalid-email")) {
        errorMessage = "Invalid email format.";
      }

      Get.snackbar(
          "Failed",
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
