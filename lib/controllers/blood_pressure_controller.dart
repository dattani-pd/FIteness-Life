import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/model.dart';

class BloodPressureController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var bpHistory = <BloodPressureModel>[].obs;
  var isLoading = true.obs;

  // Controllers for text inputs
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final pulseController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBPHistory();
  }

  @override
  void onClose() {
    systolicController.dispose();
    diastolicController.dispose();
    pulseController.dispose();
    super.onClose();
  }

  // ✅ FETCH HISTORY
  void fetchBPHistory() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestore
        .collection('users')
        .doc(uid)
        .collection('blood_pressure_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      bpHistory.value = snapshot.docs
          .map((doc) => BloodPressureModel.fromFirestore(doc.data(), doc.id))
          .toList();
      isLoading.value = false;
    });
  }

  // ✅ SAVE BP LOG
  Future<void> saveBPLog() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String sysText = systolicController.text.trim();
    String diaText = diastolicController.text.trim();
    String pulseText = pulseController.text.trim();

    if (sysText.isEmpty || diaText.isEmpty) {
      Get.snackbar("Error", "Please enter Systolic and Diastolic values", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      int sys = int.parse(sysText);
      int dia = int.parse(diaText);
      int pulse = pulseText.isNotEmpty ? int.parse(pulseText) : 0;

      await _firestore.collection('users').doc(uid).collection('blood_pressure_logs').add({
        'systolic': sys,
        'diastolic': dia,
        'pulse': pulse,
        'date': FieldValue.serverTimestamp(),
      });

      // Clear inputs
      systolicController.clear();
      diastolicController.clear();
      pulseController.clear();
      Get.back(); // Close dialog or bottom sheet

      Get.snackbar("Success", "Blood Pressure logged successfully", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      print("Error saving BP: $e");
      Get.snackbar("Error", "Invalid input or connection error", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

