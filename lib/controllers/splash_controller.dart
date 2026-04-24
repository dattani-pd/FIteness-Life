import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_life/screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/constant.dart';



class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Animation Setup
    animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animController, curve: Curves.easeIn));
    slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: animController, curve: Curves.easeOutBack));
    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animController, curve: Curves.elasticOut));
    animController.forward();

    _initializationSequence();
  }

  void _initializationSequence() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final String localRole = AppConstants.role;
      final String localUserId = AppConstants.userId;
      final String? authUid = _auth.currentUser?.uid;

      print("🟦 Splash init: localUserId=$localUserId localRole=$localRole authUid=$authUid");

      // 1. Trainer Check: Must verify approval with Firebase if local role is 'trainer'
      if (localUserId.isNotEmpty && localRole == 'trainer') {
        print("🔄 Trainer detected: Verifying approval status...");
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          await _fetchAndSaveUserData(firebaseUser.uid);
          return;
        }
      }

      // 2. Fast Boot: Trust Local Data for Admin/User
      if (localUserId.isNotEmpty && localRole.isNotEmpty) {
        print("🚀 Fast Boot: Using Local Data ($localRole)");
        _navigateBasedOnRole(localRole);
        return;
      }

      // 3. Fallback: Check Firebase
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        print("🌐 Syncing: Fetching fresh data...");
        await _fetchAndSaveUserData(firebaseUser.uid);
      } else {
        print("❌ No User -> Login");
        Get.offAllNamed(LoginScreen.pageId);
      }
    } catch (e, st) {
      print("🔴 Splash init error: $e");
      print(st);
      Get.offAllNamed(LoginScreen.pageId);
    }
  }

  Future<void> _fetchAndSaveUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        String role = data['role'] ?? 'user';
        String email = data['email'] ?? '';
        bool isApproved = data['isApproved'] == true || data['isApproved'] == "true";

        await AppConstants.setUserId(uid);
        await AppConstants.setRole(role);
        await AppConstants.setEmail(email);
        await AppConstants.setApproved(isApproved);

        _navigateBasedOnRole(role);
      } else {
        Get.offAllNamed(LoginScreen.pageId);
      }
    } catch (e) {
      print("🔴 Error: $e");
      Get.offAllNamed(LoginScreen.pageId);
    }
  }

  // --- UPDATED NAVIGATION LOGIC ---
  void _navigateBasedOnRole(String role) {
    if (role == 'trainer') {
      // Logic for Trainers: Check approval

      Get.offAllNamed(MainNavigationScreen.pageId); // Go to Unified Home

    } else {
      // Logic for Admin & User: Go straight to Home
      Get.offAllNamed(MainNavigationScreen.pageId); // Go to Unified Home
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}