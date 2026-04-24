import 'dart:async';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HealthServiceController extends GetxController {
  // --- HEALTH CONNECT VARIABLES ---
  final Health health = Health();
  var totalStepsHistory = 0.obs;
  var weight = 0.0.obs;
  var heartRate = 0.obs;
  var sleepHours = "0h 0m".obs;
  var dailyDistance = 0.0.obs;

  // ✅ List to store history for the UI
  var stepHistory = <Map<String, dynamic>>[].obs;

  var isLinked = false.obs;
  var isLoading = false.obs;

  // --- LIVE SENSOR VARIABLES ---
  var liveStepCount = 0.obs;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int _stepsAtStartOfDay = 0;

  final types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.DISTANCE_DELTA,
  ];

  @override
  void onInit() {
    super.onInit();
    initLivePedometer();
    _loadHistoryFromFirebase(); // ✅ Load on startup
    _fetchProfileFromFirebase();
    _fetchLastHeartRateFromFirebase();
  }

  // ==========================================
  // PART 1: LIVE PEDOMETER (PERSISTENT FIX)
  // ==========================================
  void initLivePedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      await _loadDailyStepOffset();

      try {
        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(
          onLiveStepCount,
          onError: onLiveStepError,
          cancelOnError: true,
        );

        _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
        _pedestrianStatusStream.listen((event) => print("🚶 Status: ${event.status}"));
      } catch (e) {
        print("❌ Pedometer Error: $e");
      }
    }
  }

  Future<void> _loadDailyStepOffset() async {
    final prefs = await SharedPreferences.getInstance();
    String todayKey = DateTime.now().toIso8601String().split('T')[0];
    String? savedDate = prefs.getString('step_date');

    if (savedDate != todayKey) {
      _stepsAtStartOfDay = 0;
      liveStepCount.value = 0;
      await prefs.setString('step_date', todayKey);
      await prefs.setInt('steps_offset', 0);
      await prefs.setInt('last_known_steps', 0);
    } else {
      _stepsAtStartOfDay = prefs.getInt('steps_offset') ?? 0;
      liveStepCount.value = prefs.getInt('last_known_steps') ?? 0;
    }
  }

  void onLiveStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    int totalSensorSteps = event.steps;

    if (_stepsAtStartOfDay == 0) {
      _stepsAtStartOfDay = totalSensorSteps;
      await prefs.setInt('steps_offset', _stepsAtStartOfDay);
    }

    int todaySteps = totalSensorSteps - _stepsAtStartOfDay;

    if (todaySteps < 0) {
      todaySteps = totalSensorSteps;
      _stepsAtStartOfDay = 0;
      await prefs.setInt('steps_offset', 0);
    }

    liveStepCount.value = todaySteps;
    await prefs.setInt('last_known_steps', todaySteps);
  }

  void onLiveStepError(error) {
    print("❌ Sensor Error: $error");
  }

  // ==========================================
  // PART 2: HEALTH CONNECT & FIREBASE SYNC
  // ==========================================
  Future<void> authorizeHealth() async {
    isLoading.value = true;
    try {
      bool? hasPermissions = await health.hasPermissions(types);
      if (hasPermissions != true) {
        bool requested = await health.requestAuthorization(types);
        if (requested) {
          isLinked.value = true;
          await fetchHealthConnectData();
          Get.snackbar("Success", "Synced Health Data!");
        } else {
          isLinked.value = false;
          Get.snackbar("Permission", "Please allow permissions in settings.");
        }
      } else {
        isLinked.value = true;
        await fetchHealthConnectData();
      }
    } catch (e) {
      print("🔴 [Health Connect] Error: $e");
      if (e.toString().contains("Health Connect is not available")) {
        health.installHealthConnect();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHealthConnectData() async {
    if (!isLinked.value) return;
    print("🔵 [Health Connect] Fetching History...");

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final yesterday = midnight.subtract(const Duration(days: 1));

    try {
      // 1. Historical Steps
      int? steps = await health.getTotalStepsInInterval(midnight, now);
      totalStepsHistory.value = steps ?? 0;
      print("   [History] Steps: $steps");

      // ⭐ 2. NEW: Calculate Distance (Meters to Miles)
      List<HealthDataPoint> distanceData = await health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: midnight,
        endTime: now,
      );

      double totalMeters = 0;
      for (var data in distanceData) {
        // ડેટા ભેગો કરો (Sum up segments)
        if (data.value is NumericHealthValue) {
          totalMeters += (data.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      // મીટરને માઈલ્સમાં ફેરવો (1 Meter = 0.000621371 Miles)
      // જો કિલોમીટર જોઈએ તો: totalMeters / 1000
      dailyDistance.value = totalMeters * 0.000621371;

      print("📏 Distance: ${dailyDistance.value.toStringAsFixed(2)} mi");

      // 2. Weight
      List<HealthDataPoint> weightData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now,
      );
      if (weightData.isNotEmpty) {
        weightData.sort((a, b) => a.dateTo.compareTo(b.dateTo));
        if (weightData.last.value is NumericHealthValue) {
          double fetchedWeight = (weightData.last.value as NumericHealthValue).numericValue.toDouble();
          weight.value = fetchedWeight;

          await _updateWeightInFirebase(fetchedWeight);
        }
      }

      // 3. Heart Rate
      List<HealthDataPoint> heartData = await health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: now.subtract(const Duration(hours: 24)),
        endTime: now,
      );
      if (heartData.isNotEmpty) {
        heartData.sort((a, b) => a.dateTo.compareTo(b.dateTo));
        if (heartData.last.value is NumericHealthValue) {
          heartRate.value = (heartData.last.value as NumericHealthValue).numericValue.toInt();
        }
      }

      // 4. Sleep
      List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: yesterday.subtract(const Duration(hours: 12)),
        endTime: now,
      );
      int totalMinutes = 0;
      for (var session in sleepData) {
        if (session.dateTo.isAfter(yesterday)) {
          totalMinutes += session.dateTo.difference(session.dateFrom).inMinutes;
        }
      }
      if (totalMinutes > 0) {
        sleepHours.value = "${totalMinutes ~/ 60}h ${totalMinutes % 60}m";
      }

      // ✅ 5. SYNC TO FIREBASE
      await _syncStepsToFirebase();

    } catch (e) {
      print("❌ [Health Connect] Fetch Error: $e");
    }
  }

  // ✅ FIXED: Only upload if we have valid data (prevents overwriting with 0)
  Future<void> _syncStepsToFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("❌ No user logged in");
      return;
    }

    print("🔥 [Firebase] Starting Step Sync...");
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    int uploadCount = 0;

    // Upload last 30 days
    for (int i = 0; i < 30; i++) {
      DateTime date = now.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      if (endOfDay.isAfter(now)) endOfDay = now;

      try {
        int? healthConnectSteps = await health.getTotalStepsInInterval(startOfDay, endOfDay);
        int stepsToUpload = healthConnectSteps ?? 0;

        String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        bool isToday = (date.year == now.year && date.month == now.month && date.day == now.day);

        // Use live sensor for today if higher
        if (isToday && liveStepCount.value > stepsToUpload) {
          stepsToUpload = liveStepCount.value;
        }

        // ✅ KEY FIX: Only upload if we have actual data
        // Don't overwrite existing Firebase data with 0
        if (isToday || stepsToUpload > 0) {
          // Check if Firebase already has higher value
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('steps')
              .doc(dateKey);

          // Get existing data first
          DocumentSnapshot existingDoc = await docRef.get();
          int existingSteps = 0;

          if (existingDoc.exists) {
            existingSteps = (existingDoc.data() as Map<String, dynamic>)['steps'] ?? 0;
          }

          // Only upload if new data is higher OR it's today (always update today)
          if (isToday || stepsToUpload > existingSteps) {
            print("📤 Uploading $dateKey: $stepsToUpload steps (was: $existingSteps)");

            batch.set(docRef, {
              'date': dateKey,
              'steps': stepsToUpload,
              'timestamp': startOfDay,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            uploadCount++;
          } else {
            print("⏭️ Skipping $dateKey: existing $existingSteps > new $stepsToUpload");
          }
        } else {
          print("⏭️ Skipping $dateKey: no data (0 steps)");
        }

      } catch (e) {
        print("⚠️ Error processing day $i: $e");
      }
    }

    if (uploadCount > 0) {
      await batch.commit();
      print("✅ Upload complete! ($uploadCount records updated)");
    } else {
      print("ℹ️ No new data to upload");
    }

    // Load back from Firebase
    await _loadHistoryFromFirebase();
  }

  // ✅ NEW: Separate method to load history from Firebase
  Future<void> _loadHistoryFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("❌ No user for history fetch");
      return;
    }

    print("📥 [Firebase] Loading step history...");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('steps')
          .orderBy('date', descending: true) // ✅ Order by 'date' field, not 'timestamp'
          .limit(30)
          .get();

      print("📊 Found ${querySnapshot.docs.length} documents");

      List<Map<String, dynamic>> historyList = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        String dateStr = data['date'] ?? doc.id;
        int steps = data['steps'] ?? 0;

        print("   📅 $dateStr: $steps steps");

        // Parse date string "2026-01-16" to DateTime
        try {
          List<String> parts = dateStr.split('-');
          if (parts.length == 3) {
            DateTime date = DateTime(
              int.parse(parts[0]), // year
              int.parse(parts[1]), // month
              int.parse(parts[2]), // day
            );

            historyList.add({
              'date': "${date.day}/${date.month}",
              'steps': steps,
              'day': _getDayName(date.weekday),
            });
          }
        } catch (e) {
          print("⚠️ Date parse error for $dateStr: $e");
        }
      }

      stepHistory.value = historyList;
      print("✅ [UI] History loaded: ${historyList.length} records");

    } catch (e) {
      print("❌ Error loading history: $e");
      print("   Stack trace: ${StackTrace.current}");
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // 📤 FIREBASE: Save Weight to Database
  Future<void> _updateWeightInFirebase(double newWeight) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || newWeight <= 0) return;

    try {
      print("⚖️ Saving new weight to Firebase: $newWeight");
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'weight': newWeight,
        'lastHealthSync': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Failed to save weight: $e");
    }
  }

  // 📥 FIREBASE: Fetch Weight & Height on Startup
  Future<void> _fetchProfileFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      print("📥 Loading Profile Data from Firebase...");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        // ⚖️ Weight (વજન)
        if (data.containsKey('weight')) {
          var w = data['weight'];
          // ચેક કરીએ કે વજન Number છે કે String
          if (w is num) {
            weight.value = w.toDouble();
          } else if (w is String) {
            weight.value = double.tryParse(w) ?? 0.0;
          }
          print("✅ Weight Updated from Firebase: ${weight.value}");
        }

        // 📏 Height (ઊંચાઈ)
        if (data.containsKey('height')) {
          var h = data['height'];
          print("✅ Height found in Firebase: $h");
          // જો તમે height માટે કોઈ variable બનાવ્યો હોય (જેમ કે height.value), તો અહીં સેટ કરી શકો છો.
        }
      }
    } catch (e) {
      print("❌ Error loading profile data: $e");
    }
  }

  // 💓 FIREBASE: Fetch Last Heart Rate on Startup
  Future<void> _fetchLastHeartRateFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      print("💓 Loading Last Heart Rate from Firebase...");

      // છેલ્લો રેકોર્ડ લાવવા માટે date થી sort કરીએ
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('heart_rate')
          .orderBy('date', descending: true) // સૌથી છેલ્લો ડેટા પહેલા આવશે
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        if (data.containsKey('bpm')) {
          heartRate.value = data['bpm'] as int;
          print("✅ Last Heart Rate loaded: ${heartRate.value} BPM");
        }
      }
    } catch (e) {
      print("❌ Error loading heart rate: $e");
    }
  }
}
