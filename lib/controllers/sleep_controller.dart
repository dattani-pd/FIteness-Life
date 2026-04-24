// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../model/model.dart';
//
// class SleepController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   var sleepHistory = <SleepLogModel>[].obs;
//   var isLoading = true.obs;
//
//   // Temporary variables for the UI
//   var selectedBedTime = TimeOfDay(hour: 22, minute: 0).obs; // 10:00 PM
//   var selectedWakeTime = TimeOfDay(hour: 7, minute: 0).obs; // 7:00 AM
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchSleepHistory();
//   }
//
//   // ✅ FETCH HISTORY
//   void fetchSleepHistory() {
//     String? uid = _auth.currentUser?.uid;
//     if (uid == null) return;
//
//     _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('sleep_logs')
//         .orderBy('date', descending: true) // Newest first
//         .snapshots()
//         .listen((snapshot) {
//       sleepHistory.value = snapshot.docs
//           .map((doc) => SleepLogModel.fromFirestore(doc.data(), doc.id))
//           .toList();
//       isLoading.value = false;
//     });
//   }
//
//   // ✅ SAVE SLEEP LOG
//   Future<void> saveSleepLog() async {
//     String? uid = _auth.currentUser?.uid;
//     if (uid == null) return;
//
//     try {
//       isLoading.value = true;
//
//       // 1. Convert TimeOfDay to DateTime
//       final now = DateTime.now();
//
//       // Bedtime is usually "Yesterday" or "Today" depending on logic,
//       // but for simplicity, we assume we are logging for "Last Night".
//       // Let's construct DateTime objects.
//
//       DateTime bedDateTime = DateTime(now.year, now.month, now.day, selectedBedTime.value.hour, selectedBedTime.value.minute);
//       DateTime wakeDateTime = DateTime(now.year, now.month, now.day, selectedWakeTime.value.hour, selectedWakeTime.value.minute);
//
//       // Logic: If Bedtime is AFTER Wake time (e.g. Bed 11PM, Wake 7AM),
//       // it means Bedtime was technically yesterday.
//       if (bedDateTime.isAfter(wakeDateTime)) {
//         bedDateTime = bedDateTime.subtract(const Duration(days: 1));
//       }
//
//       // 2. Calculate Duration
//       int durationMinutes = wakeDateTime.difference(bedDateTime).inMinutes;
//
//       // 3. Save to Firebase
//       await _firestore.collection('users').doc(uid).collection('sleep_logs').add({
//         'bedTime': Timestamp.fromDate(bedDateTime),
//         'wakeTime': Timestamp.fromDate(wakeDateTime),
//         'durationMinutes': durationMinutes,
//         'date': Timestamp.fromDate(now), // Logged date
//       });
//
//       Get.snackbar("Success", "Sleep logged: ${durationMinutes ~/ 60}h ${durationMinutes % 60}m", backgroundColor: Colors.green, colorText: Colors.white);
//
//     } catch (e) {
//       print("Error saving sleep: $e");
//       Get.snackbar("Error", "Could not save sleep data", backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // UI Helper: Pick Time
//   Future<void> pickTime(BuildContext context, bool isBedTime) async {
//     TimeOfDay initial = isBedTime ? selectedBedTime.value : selectedWakeTime.value;
//
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initial,
//       builder: (context, child) => Theme(
//           data: Get.isDarkMode ? ThemeData.dark() : ThemeData.light(),
//           child: child!
//       ),
//     );
//
//     if (picked != null) {
//       if (isBedTime) {
//         selectedBedTime.value = picked;
//       } else {
//         selectedWakeTime.value = picked;
//       }
//     }
//   }
// }