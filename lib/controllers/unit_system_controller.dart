import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==========================================
// CONTROLLER: HANDLES LOGIC & FIREBASE
// ==========================================
class UnitSystemController extends GetxController {
  var selectedSystem = "Metric".obs; // Default
  var isLoading = true.obs;

  // Reactive Unit Values
  var weightUnit = "kg".obs;
  var heightUnit = "cm".obs;
  var circumferenceUnit = "cm".obs;
  var waterUnit = "ml".obs;
  var foodVolumeUnit = "ml".obs;
  var foodWeightUnit = "g".obs;
  var distanceUnit = "km".obs;

  @override
  void onInit() {
    super.onInit();
    loadUnitSettings();
  }

  // 1. Load from Firebase
  void loadUnitSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data()!.containsKey('unitSystem')) {
          String savedSystem = doc.data()!['unitSystem'];
          updateUnits(savedSystem);
        } else {
          updateUnits("Metric"); // Default
        }
      } catch (e) {
        print("Error loading units: $e");
      }
    }
    isLoading.value = false;
  }

  // 2. Switch System (Metric <-> Imperial)
  void setSystem(String system) async {
    updateUnits(system);

    // Save to Firebase
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'unitSystem': system,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // 3. Update Display Values based on System
  void updateUnits(String system) {
    selectedSystem.value = system;
    if (system == "Metric") {
      weightUnit.value = "kg";
      heightUnit.value = "cm";
      circumferenceUnit.value = "cm";
      waterUnit.value = "ml";
      foodVolumeUnit.value = "ml";
      foodWeightUnit.value = "g";
      distanceUnit.value = "km";
    } else {
      // Imperial / US Standard
      weightUnit.value = "lb";
      heightUnit.value = "ft";
      circumferenceUnit.value = "in";
      waterUnit.value = "fl oz";
      foodVolumeUnit.value = "cup";
      foodWeightUnit.value = "oz";
      distanceUnit.value = "miles";
    }
  }
}
