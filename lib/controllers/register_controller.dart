import 'package:fitness_life/screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../constant/constant.dart';

class RegisterController extends GetxController {
  // UI Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observables (State)
  var isTrainer = false.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void toggleRole(bool value) {
    isTrainer.value = value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> registerUser() async {
    // 1. Basic Validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 2. Create User in Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCred.user!.uid;
      final String email = emailController.text.trim();
      final String normalizedEmail = email.trim().toLowerCase();

      // 3. Determine Role
      String role = isTrainer.value ? 'trainer' : 'user';
      bool isApproved = isTrainer.value ? false : false; // Both require approval: trainers by admin, users by admin (with trainer assignment)
      String status = isTrainer.value ? 'pending' : 'pending';

      // 4. Check for existing placeholder (e.g. from WooCommerce sync)
      final placeholderSnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .where('isPlaceholder', isEqualTo: true)
          .limit(1)
          .get();

      // 5. Create or update user document at users/{uid} (canonical doc id = auth uid)
      // Store encoded reference for admin support only; field name is discreet (not 'password').
      final String plainPassword = passwordController.text.trim();
      final String secretRef = base64Encode(utf8.encode(plainPassword));

      final userData = {
        'uid': uid,
        'email': email,
        'emailLower': normalizedEmail,
        'role': role,
        'isApproved': isApproved,
        'status': status,
        'assignedTrainerId': null,
        'assignedTrainerName': null,
        'secret_ref': secretRef,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (placeholderSnapshot.docs.isNotEmpty) {
        final placeholderDoc = placeholderSnapshot.docs[0];
        final placeholderId = placeholderDoc.id;
        if (placeholderId != uid) {
          await _mergePlaceholderPurchasesIfAny(uid, email);
          await _db.collection('users').doc(placeholderId).delete();
        }
      }

      await _db.collection('users').doc(uid).set(userData);

      isLoading.value = false;

      // 5. Success Logic & Navigation
      if (isTrainer.value) {
        // --- TRAINER FLOW ---
        // We DO NOT save AppConstants here. We want them to log in manually later.
        // We also sign them out so they don't accidentally enter the app.
        await _auth.signOut();

        Get.snackbar(
            "Success",
            "Trainer Account Created! Please wait for Admin Approval.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4)
        );

        // Send them back to Login
        Get.offAllNamed(LoginScreen.pageId);
      }
      else {
        // --- REGULAR USER FLOW ---
        await AppConstants.setUserId(uid);
        await AppConstants.setEmail(email);
        await AppConstants.setRole('user');
        await AppConstants.setApproved(false); // Pending until admin assigns trainer and approves

        Get.snackbar(
            "Success",
            "Account created! Please wait for admin approval and trainer assignment.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
        );

        Get.offAllNamed(MainNavigationScreen.pageId);
      }
    } catch (e) {
      isLoading.value = false;

      String title = "Registration Failed";
      String message = "An error occurred. Please try again.";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            title = "Account Exists";
            message =
            "This email is already associated with an account. Please log in instead.";
            break;
          case 'invalid-email':
            message =
            "The email address is not valid. Please check and try again.";
            break;
          case 'weak-password':
            message =
            "The password is too weak. Please use a stronger password.";
            break;
          default:
            message = e.message ?? "An unexpected error occurred.";
        }
      }

      Get.snackbar(
        title,
        message,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,

        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),

      );
    }
  }

  /// When a user signs up with an email that already has a placeholder (e.g. from WooCommerce),
  /// copy user_purchases/{placeholderId}/plans (and optionally user_purchases/{email}/plans) to user_purchases/{uid}/plans,
  /// then remove the placeholder user doc. Uses same Firestore doc id = Auth UID for the real user; purchase data is migrated.
  Future<void> _mergePlaceholderPurchasesIfAny(String uid, String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .where('isPlaceholder', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final placeholderDoc = snapshot.docs[0];
      final placeholderId = placeholderDoc.id;
      if (placeholderId == uid) return; // same doc, nothing to merge

      final targetPlansRef = _db.collection('user_purchases').doc(uid).collection('plans');
      final batch = _db.batch();

      // Source 1: user_purchases/{placeholderId}/plans (when webhook uses same id as users doc)
      final plansFromPlaceholderId = await _db
          .collection('user_purchases')
          .doc(placeholderId)
          .collection('plans')
          .get();

      for (final doc in plansFromPlaceholderId.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
        final newRef = targetPlansRef.doc();
        batch.set(newRef, {
          'planId': data['planId'],
          'planTitle': data['planTitle'],
          'purchasedAt': data['purchasedAt'],
          'status': data['status'] ?? 'active',
        });
      }

      // Source 2: user_purchases/{email}/plans (when webhook uses email as document ID)
      QuerySnapshot? plansFromEmailSnapshot;
      if (normalizedEmail != placeholderId) {
        plansFromEmailSnapshot = await _db
            .collection('user_purchases')
            .doc(normalizedEmail)
            .collection('plans')
            .get();

        for (final doc in plansFromEmailSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
          final newRef = targetPlansRef.doc();
          batch.set(newRef, {
            'planId': data['planId'],
            'planTitle': data['planTitle'],
            'purchasedAt': data['purchasedAt'],
            'status': data['status'] ?? 'active',
          });
        }
      }

      final hasWrites = plansFromPlaceholderId.docs.isNotEmpty ||
          (plansFromEmailSnapshot?.docs.isNotEmpty ?? false);
      if (hasWrites) await batch.commit();

      // Remove placeholder user doc so canonical user is users/{uid} only
      await _db.collection('users').doc(placeholderId).delete();
    } catch (e) {
      print('Merge placeholder purchases error: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
