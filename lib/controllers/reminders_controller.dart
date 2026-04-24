import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';
import '../services/notification_service.dart'; // Import the service
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';



class RemindersController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  // IDs
  static const int WORKOUT_ID = 1;
  static const int BREAKFAST_ID = 2;
  static const int LUNCH_ID = 3;
  static const int DINNER_ID = 4;

  // Water uses a range of IDs
  static const int WATER_START_ID = 100;

  var workoutEnabled = false.obs;
  var workoutTime = "07:00 AM".obs;

  var breakfastEnabled = false.obs;
  var breakfastTime = "08:00 AM".obs;

  var lunchEnabled = false.obs;
  var lunchTime = "01:00 PM".obs;

  var dinnerEnabled = false.obs;
  var dinnerTime = "08:00 PM".obs;

  var hydrationEnabled = false.obs;

  // 👇 NEW: Store the interval in minutes (Default = 120 min / 2 hours)
  var hydrationInterval = 120.obs;
  var userRole = "".obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    userRole.value = AppConstants.role;
    print("👤 Reminder Controller - User Role: ${userRole.value}");
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _notificationService.init();
    await loadSettings();
    await _loadFromFirebase();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    workoutEnabled.value = prefs.getBool('workout_enabled') ?? false;
    workoutTime.value = prefs.getString('workout_time') ?? "07:00 AM";

    breakfastEnabled.value = prefs.getBool('breakfast_enabled') ?? false;
    breakfastTime.value = prefs.getString('breakfast_time') ?? "08:00 AM";

    lunchEnabled.value = prefs.getBool('lunch_enabled') ?? false;
    lunchTime.value = prefs.getString('lunch_time') ?? "01:00 PM";

    dinnerEnabled.value = prefs.getBool('dinner_enabled') ?? false;
    dinnerTime.value = prefs.getString('dinner_time') ?? "08:00 PM";

    hydrationEnabled.value = prefs.getBool('hydration_enabled') ?? false;

    // 👇 SAFETY FIX: Check if the saved value is valid
    int savedInterval = prefs.getInt('hydration_interval') ?? 120;

    // If the saved value is less than 30 (like your test '2'), reset it to 30
    if (savedInterval < 30) {
      savedInterval = 30;
      await prefs.setInt('hydration_interval', 30); // Update storage
    }

    hydrationInterval.value = savedInterval;
  }

  // ✅ LOAD from Separate Collection
  Future<void> _loadFromFirebase() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // 👇 We read the Main User Document directly
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // 👇 Check if the 'reminder_settings' Map exists inside the user doc
        if (data.containsKey('reminder_settings')) {
          Map<String, dynamic> settings = data['reminder_settings'];

          workoutEnabled.value = settings['workout_enabled'] ?? false;
          workoutTime.value = settings['workout_time'] ?? "07:00 AM";

          breakfastEnabled.value = settings['breakfast_enabled'] ?? false;
          breakfastTime.value = settings['breakfast_time'] ?? "08:00 AM";

          lunchEnabled.value = settings['lunch_enabled'] ?? false;
          lunchTime.value = settings['lunch_time'] ?? "01:00 PM";

          dinnerEnabled.value = settings['dinner_enabled'] ?? false;
          dinnerTime.value = settings['dinner_time'] ?? "08:00 PM";

          hydrationEnabled.value = settings['hydration_enabled'] ?? false;
          hydrationInterval.value = settings['hydration_interval'] ?? 120;

          if (hydrationEnabled.value) toggleHydration(forceRestart: true);
        }
      }
    } catch (e) {
      print("Error loading reminders from Firebase: $e");
    }
  }

  // ✅ NEW SAVE: Writes directly to User Document
  Future<void> _saveToFirebase() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // 👇 Save as a Field (Map) inside the User Document
      // 'merge: true' ensures we don't delete other user data (like email, name, etc.)
      await _firestore.collection('users').doc(uid).set({
        'reminder_settings': {
          'workout_enabled': workoutEnabled.value,
          'workout_time': workoutTime.value,
          'breakfast_enabled': breakfastEnabled.value,
          'breakfast_time': breakfastTime.value,
          'lunch_enabled': lunchEnabled.value,
          'lunch_time': lunchTime.value,
          'dinner_enabled': dinnerEnabled.value,
          'dinner_time': dinnerTime.value,
          'hydration_enabled': hydrationEnabled.value,
          'hydration_interval': hydrationInterval.value,
          'last_updated': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      print("✅ Reminders saved directly to User Profile");
    } catch (e) {
      print("❌ Error saving to Firebase: $e");
    }
  }

  // --- GENERAL TOGGLE ---
  Future<void> toggleReminder(String key, RxBool variable, int id, String title, String body, String timeStr) async {
    variable.value = !variable.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${key}_enabled', variable.value);
    _saveToFirebase();

    if (variable.value) {
      await _schedule(id, title, body, timeStr);
      Get.snackbar("Reminder On", "$title scheduled for $timeStr", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      await _notificationService.cancelNotification(id);
      Get.snackbar("Reminder Off", "$title cancelled", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 👇 NEW: CHANGE INTERVAL FUNCTION ---
  Future<void> updateHydrationInterval(int minutes) async {
    hydrationInterval.value = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hydration_interval', minutes);
    _saveToFirebase();

    // If currently enabled, restart the schedule with new time
    if (hydrationEnabled.value) {
      await toggleHydration(forceRestart: true);
    }
  }

  // --- WATER TOGGLE (Dynamic Calculation) ---
  Future<void> toggleHydration({bool forceRestart = false}) async {
    if (!forceRestart) {
      hydrationEnabled.value = !hydrationEnabled.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hydration_enabled', hydrationEnabled.value);
      _saveToFirebase();
    }

    // 1. Always Cancel old alarms first (Clear IDs 100 to 150 to be safe)
    for (int i = 0; i < 50; i++) {
      await _notificationService.cancelNotification(WATER_START_ID + i);
    }

    if (hydrationEnabled.value) {
      // 2. Calculate times from 8:00 AM to 10:00 PM
      int startMinutes = 8 * 60;  // 8:00 AM
      int endMinutes = 22 * 60;   // 10:00 PM
      int interval = hydrationInterval.value;

      int currentId = WATER_START_ID;

      for (int time = startMinutes; time <= endMinutes; time += interval) {
        int hour = time ~/ 60;
        int minute = time % 60;

        // Convert back to formatted String (e.g., "02:30 PM")
        TimeOfDay tod = TimeOfDay(hour: hour, minute: minute);
        String timeStr = _formatTime(tod);

        await _schedule(currentId, "Drink Water 💧", "Time to hydrate!", timeStr);
        currentId++;
      }

      String intervalText = interval >= 60 ? "${interval ~/ 60} Hour(s)" : "$interval Mins";
      Get.snackbar("Hydration On", "Reminders set every $intervalText", backgroundColor: Colors.blue, colorText: Colors.white);
    } else {
      Get.snackbar("Hydration Off", "Water reminders cancelled", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- HELPER FUNCTIONS ---

  String _formatTime(TimeOfDay time) {
    // Simple helper to format TimeOfDay to "hh:mm a" string
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Future<void> pickTime(BuildContext context, String key, RxString timeVariable, int id, String title, String body, RxBool isEnabled) async {
    TimeOfDay initial = _parseTime(timeVariable.value);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(data: Get.isDarkMode ? ThemeData.dark() : ThemeData.light(), child: child!),
    );

    if (picked != null) {
      final String formatted = picked.format(context);
      timeVariable.value = formatted;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${key}_time', formatted);
      _saveToFirebase();

      if (isEnabled.value) {
        await _notificationService.cancelNotification(id);
        await _schedule(id, title, body, formatted);
      }
    }
  }

  Future<void> _schedule(int id, String title, String body, String timeStr) async {
    TimeOfDay time = _parseTime(timeStr);
    await _notificationService.scheduleDailyNotification(
      id: id,
      title: title,
      body: body,
      time: time,
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      bool isPM = parts[1] == 'PM';
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }
}