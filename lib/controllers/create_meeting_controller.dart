import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl package to pubspec.yaml for formatting

class CreateMeetingController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text Controllers
  final titleController = TextEditingController();
  final linkController = TextEditingController();
  final descriptionController = TextEditingController();

  // Variables
  var isLoading = false.obs;
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();

  // Computed String for UI
  String get dateText => selectedDate.value == null
      ? "Select Date"
      : DateFormat('MMM dd, yyyy').format(selectedDate.value!);

  String get timeText => selectedTime.value == null
      ? "Select Time"
      : selectedTime.value!.format(Get.context!);

  // --- ACTIONS ---

  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8B0000)), // Red Theme
          ),
          child: child!,
        );
      },
    );
    if (picked != null) selectedDate.value = picked;
  }

  void pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8B0000)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) selectedTime.value = picked;
  }

  Future<void> createMeeting() async {
    if (titleController.text.isEmpty || linkController.text.isEmpty ||
        selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;

      // Combine Date and Time
      DateTime finalDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      await _db.collection('live_classes').add({
        'trainerId': uid,
        'trainerName': _auth.currentUser?.email ?? "Trainer",
        'title': titleController.text.trim(),
        'meetingLink': linkController.text.trim(),
        'description': descriptionController.text.trim(),
        'startTime': Timestamp.fromDate(finalDateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'upcoming', // upcoming, live, ended
      });

      Get.back(); // Close screen
      Get.snackbar("Success", "Class Scheduled Successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Error", "Failed to create meeting: $e");
    } finally {
      isLoading.value = false;
    }
  }
}