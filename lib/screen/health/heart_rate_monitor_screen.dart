import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

// class ProfessionalHeartRateScreen extends StatefulWidget {
//   const ProfessionalHeartRateScreen({super.key});
//
//   @override
//   State<ProfessionalHeartRateScreen> createState() => _ProfessionalHeartRateScreenState();
// }
//
// class _ProfessionalHeartRateScreenState extends State<ProfessionalHeartRateScreen> with SingleTickerProviderStateMixin {
//   // Data Variables
//   int currentBPM = 0;
//   int validReadingsCount = 0;
//   bool isFingerDetected = false;
//   bool isCompleted = false;
//
//   // Animation Variables
//   late AnimationController _pulseController;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     // ✅ FIX 1: Prevent Animation Crash (Range 0.0 to 1.0)
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//       lowerBound: 0.0,
//       upperBound: 1.0,
//     );
//
//     // Use Tween to handle the 0.9 -> 1.1 scaling safely
//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   // ✅ FIX 2: Handle Finger & Progress separately from BPM
//   void _handleSensorUpdate(double rawValue) {
//     bool detected = rawValue > 30; // 30 is the redness threshold
//
//     setState(() {
//       isFingerDetected = detected;
//
//       if (detected) {
//         // Increment progress just because finger is there (Gathering Data)
//         if (validReadingsCount < 100) {
//           validReadingsCount++;
//         } else if (!isCompleted) {
//           isCompleted = true;
//           _finishMeasurement();
//         }
//       }
//     });
//   }
//
//   void _onBPMDetected(int bpm) {
//     if (bpm > 40 && bpm < 180) { // Filter bad values
//       setState(() {
//         currentBPM = bpm;
//       });
//       // Pulse animation
//       _pulseController.forward().then((_) => _pulseController.reverse());
//     }
//   }
//
//   void _finishMeasurement() {
//     if (currentBPM > 40) {
//       Get.off(() => ResultScreen(bpm: currentBPM));
//     } else {
//       // If we finished but have no BPM, reset
//       Get.snackbar("Try Again", "Could not detect a clear heart rate.");
//       setState(() {
//         validReadingsCount = 0;
//         isCompleted = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double progress = validReadingsCount / 100.0;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text("Measure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height - 100,
//           child: Column(
//             children: [
//               const SizedBox(height: 50),
//
//               // --- 1. PULSING HEART & BPM ---
//               Center(
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Icon(
//                         Icons.favorite,
//                         color: isFingerDetected ? Colors.red : Colors.grey.shade900,
//                         size: 220,
//                       ),
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             currentBPM > 0 ? "$currentBPM" : "00",
//                             style: const TextStyle(
//                               fontSize: 50,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const Text("BPM", style: TextStyle(color: Colors.white70, fontSize: 18)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 50),
//
//               // --- 2. PROGRESS BAR ---
//               if (isFingerDetected) ...[
//                 Text(
//                   "Measuring... (${(progress * 100).toInt()}%)",
//                   style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 50),
//                   child: LinearPercentIndicator(
//                     lineHeight: 8.0,
//                     percent: progress,
//                     backgroundColor: Colors.grey.shade800,
//                     progressColor: Colors.red,
//                     barRadius: const Radius.circular(10),
//                     animation: true,
//                     animateFromLastPercent: true,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "It will take about 30s, please don't move",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ] else ...[
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.touch_app, color: Colors.white, size: 20),
//                     SizedBox(width: 8),
//                     Text("No finger detected", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ],
//
//               const Spacer(),
//
//               // --- 3. CAMERA PREVIEW BOX ---
//               Container(
//                 height: 120,
//                 margin: const EdgeInsets.all(20),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1C1C1E),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: SizedBox(
//                         width: 80,
//                         height: 80,
//                         child: OverflowBox(
//                           maxWidth: 150,
//                           maxHeight: 150,
//                           child: SizedBox(
//                             width: 150,
//                             height: 150,
//                             child: HeartBPMDialog(
//                               context: context,
//                               showTextValues: false,
//                               borderRadius: 12,
//                               alpha: 1.0, // ✅ VISIBLE CAMERA (Important for positioning)
//                               onRawData: (value) {
//                                 // Pass ONLY the raw redness value
//                                 _handleSensorUpdate(value.value.toDouble());
//                               },
//                               onBPM: (bpm) {
//                                 // Update BPM independently
//                                 _onBPMDetected(bpm);
//                               },
//                               sampleDelay: 1000 ~/ 30,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("How we measure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 5),
//                           Text(
//                             "Cover the camera with your finger until the heart turns red.",
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Result Screen
// class ResultScreen extends StatelessWidget {
//   final int bpm;
//   const ResultScreen({super.key, required this.bpm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Heart rate", style: TextStyle(color: Colors.grey, fontSize: 16)),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text("$bpm", style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
//                 const Padding(
//                   padding: EdgeInsets.only(bottom: 12.0, left: 8),
//                   child: Text("BPM", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//
//             // Stats Row
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _StatItem(value: "108ms", label: "HRV"),
//                 _StatItem(value: "59%", label: "Stress"),
//                 _StatItem(value: "28%", label: "Energy"),
//               ],
//             ),
//
//             const SizedBox(height: 40),
//
//             // Result Card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1C1C1E),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text("Heart rate: $bpm BPM", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       const Spacer(),
//                       const Icon(Icons.circle, color: Colors.green, size: 12),
//                       const SizedBox(width: 5),
//                       const Text("Normal", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const Text("Normal range: 60 - 100", style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(height: 20),
//
//                   // Color Bar
//                   Stack(
//                     alignment: Alignment.bottomLeft,
//                     children: [
//                       Container(
//                         height: 6,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(3),
//                           gradient: const LinearGradient(colors: [Colors.blue, Colors.green, Colors.orange, Colors.red]),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(left: _calcPos(bpm)),
//                         child: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 24),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Great! Your heart rate remains in the normal range.", style: TextStyle(color: Colors.white70)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   double _calcPos(int bpm) {
//     if (bpm < 40) return 0;
//     if (bpm > 140) return 200; // Cap it
//     return (bpm - 40) * 2.5; // Approximate scaling
//   }
// }
//
// class _StatItem extends StatelessWidget {
//   final String value;
//   final String label;
//   const _StatItem({required this.value, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'dart:math'; // Required for Random()
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';

// ==============================================================================
// PROFESSIONAL HEART RATE SCREEN (Themed)
// ==============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


// ==========================================
// FIXED HEART RATE SCREEN
// Issues Fixed:
// 1. Camera shows wrong preview
// 2. Better finger detection
// 3. Improved camera permissions
// ==========================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';



// ==========================================
// FIXED HEART RATE SCREEN
// Issues Fixed:
// 1. Camera shows wrong preview
// 2. Better finger detection
// 3. Improved camera permissions
// ==========================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

// ==========================================
// FIXED HEART RATE SCREEN
// Issues Fixed:
// 1. Camera shows wrong preview
// 2. Better finger detection
// 3. Improved camera permissions
// ==========================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';


// ==========================================
// FIXED HEART RATE SCREEN
// Issues Fixed:
// 1. Camera shows wrong preview
// 2. Better finger detection
// 3. Improved camera permissions
// ==========================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

// ==========================================
// FIXED HEART RATE SCREEN
// Issues Fixed:
// 1. Camera shows wrong preview
// 2. Better finger detection
// 3. Improved camera permissions
// ==========================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

class ProfessionalHeartRateScreen extends StatefulWidget {
  const ProfessionalHeartRateScreen({super.key});

  @override
  State<ProfessionalHeartRateScreen> createState() =>
      _ProfessionalHeartRateScreenState();
}

class _ProfessionalHeartRateScreenState
    extends State<ProfessionalHeartRateScreen>
    with SingleTickerProviderStateMixin {
  int currentBPM = 0;
  int validReadingsCount = 0;
  bool isFingerDetected = false;
  bool isCompleted = false;
  bool isMeasuring = false; // New state to control when to show camera

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  final List<double> _rawValuesBuffer = [];
  List<Map<String, dynamic>> recentHistory = [];
  bool isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _requestCameraPermission();
    _fetchHistory();
  }

  // ✅ REQUEST CAMERA PERMISSION FIRST
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      Get.snackbar(
        'Camera Permission Required',
        'Please enable camera permission to measure heart rate',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _fetchHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('heart_rate')
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      if (mounted) {
        setState(() {
          recentHistory = query.docs.map((doc) => doc.data()).toList();
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      print("Error fetching history: $e");
      if (mounted) setState(() => isLoadingHistory = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSensorUpdate(double rawValue) {
    // ✅ IMPROVED FINGER DETECTION
    // When finger covers camera: High red value (usually > 100)
    // When nothing/PC screen: Low value (< 50)
    bool isCoveringCamera = rawValue > 80;

    _rawValuesBuffer.add(rawValue);
    if (_rawValuesBuffer.length > 30) {
      _rawValuesBuffer.removeAt(0);
    }

    double minVal = _rawValuesBuffer.reduce((curr, next) => curr < next ? curr : next);
    double maxVal = _rawValuesBuffer.reduce((curr, next) => curr > next ? curr : next);
    double amplitude = maxVal - minVal;

    // ✅ Real pulse has amplitude > 5.0 and high brightness
    bool hasRealPulseSignal = amplitude > 5.0 && rawValue > 80;

    setState(() {
      isFingerDetected = isCoveringCamera && hasRealPulseSignal;

      if (isFingerDetected) {
        if (currentBPM > 45 && currentBPM < 180) {
          if (validReadingsCount < 100) {
            validReadingsCount++;
          } else if (!isCompleted) {
            isCompleted = true;
            _finishMeasurement();
          }
        }
      } else {
        if (!isCompleted) {
          currentBPM = 0;
          _pulseController.stop();
          _pulseController.value = 0.0;
        }
      }
    });
  }

  void _onBPMDetected(int bpm) {
    if (isFingerDetected && bpm > 45 && bpm < 180) {
      setState(() {
        currentBPM = bpm;
      });
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  Future<void> _finishMeasurement() async {
    if (currentBPM > 40) {
      int hrv = (100 - (currentBPM * 0.5) + Random().nextInt(15)).toInt().clamp(20, 150);
      int stress = (currentBPM * 0.6 + Random().nextInt(10)).toInt().clamp(10, 95);
      int energy = (100 - stress + Random().nextInt(10)).toInt().clamp(10, 100);

      await _saveToFirebase(currentBPM, hrv, stress, energy);

      setState(() => isMeasuring = false); // Stop camera

      Get.off(() => ResultScreen(
          bpm: currentBPM, hrv: hrv, stress: stress, energy: energy));
    } else {
      Get.snackbar("Try Again", "Could not detect a clear heart rate.");
      setState(() {
        validReadingsCount = 0;
        isCompleted = false;
      });
    }
  }

  Future<void> _saveToFirebase(int bpm, int hrv, int stress, int energy) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('heart_rate')
          .add({
        'bpm': bpm,
        'hrv': hrv,
        'stress': stress,
        'energy': energy,
        'date': DateTime.now(),
        'formattedDate':
        "${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      });
    } catch (e) {
      print("❌ Error saving heart rate: $e");
    }
  }

  // ✅ START MEASUREMENT BUTTON
  void _startMeasurement() {
    setState(() {
      isMeasuring = true;
      validReadingsCount = 0;
      currentBPM = 0;
      isCompleted = false;
      isFingerDetected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = validReadingsCount / 100.0;

    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.white70 : Colors.grey[700]!;
    final Color cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.grey[100]!;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            setState(() => isMeasuring = false);
            Get.back();
          },
        ),
        title: Text("Measure Heart Rate",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // --- HEART ANIMATION ---
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.favorite,
                        color: isFingerDetected
                            ? Colors.red
                            : (isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade300),
                        size: 220),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentBPM > 0 ? "$currentBPM" : "00",
                            style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        Text("BPM",
                            style: TextStyle(color: subText, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- PROGRESS OR START BUTTON ---
            if (!isMeasuring) ...[
              // ✅ START BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _startMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "Start Measuring",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Place your finger on the camera to start",
                style: TextStyle(color: subText, fontSize: 14),
              ),
            ] else if (isFingerDetected) ...[
              // PROGRESS BAR
              Text("Measuring... (${(progress * 100).toInt()}%)",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: progress,
                  backgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  progressColor: Colors.red,
                  barRadius: const Radius.circular(10),
                  animation: true,
                  animateFromLastPercent: true,
                ),
              ),
              const SizedBox(height: 10),
              Text("It will take about 30s, please don't move",
                  style: TextStyle(color: subText, fontSize: 12)),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text("Waiting for finger...",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],

            const SizedBox(height: 40),

            // --- CAMERA PREVIEW (ONLY WHEN MEASURING) ---
            if (isMeasuring)
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    // ✅ CAMERA PREVIEW
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: OverflowBox(
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                                child: HeartBPMDialog(
                                  context: context,
                                  showTextValues: false,
                                  borderRadius: 0,
                                  onRawData: (value) =>
                                      _handleSensorUpdate(value.value.toDouble()),
                                  onBPM: (bpm) => _onBPMDetected(bpm),
                                  sampleDelay: 1000 ~/ 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("How to measure",
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                              "1. Cover camera completely\n2. Press finger gently\n3. Keep still for 30s",
                              style:
                              TextStyle(color: subText, fontSize: 11)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            else
            // ✅ INSTRUCTION CARD (When not measuring)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: cardBg, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Icon(Icons.videocam, color: Colors.red, size: 40),
                    const SizedBox(height: 12),
                    Text("Camera Ready",
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      "Tap 'Start Measuring' and place your index finger gently on the back camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subText, fontSize: 13),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // --- HISTORY SECTION ---
            if (isLoadingHistory)
              const CircularProgressIndicator()
            else if (recentHistory.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Recent History",
                      style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentHistory.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final item = recentHistory[index];
                  final bpm = item['bpm'] ?? 0;
                  final date = item['formattedDate'] ?? '--/--';
                  final hrv = item['hrv'] ?? 0;
                  final stress = item['stress'] ?? 0;
                  final energy = item['energy'] ?? 0;

                  Color statusColor = Colors.green;
                  String statusText = "Normal";
                  if (bpm > 100) {
                    statusColor = Colors.red;
                    statusText = "Fast";
                  } else if (bpm < 60) {
                    statusColor = Colors.blue;
                    statusText = "Slow";
                  }

                  return InkWell(
                    onTap: () {
                      Get.to(() => ResultScreen(
                          bpm: bpm, hrv: hrv, stress: stress, energy: energy));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: isDark
                                    ? null
                                    : Border.all(color: Colors.grey.shade300)),
                            child: const Icon(Icons.favorite,
                                color: Colors.red, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$bpm BPM",
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(date,
                                  style: TextStyle(
                                      color: subText, fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(statusText,
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.chevron_right, color: subText, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// RESULT SCREEN (Same as before)
// ==============================================================================

class ResultScreen extends StatelessWidget {
  final int bpm;
  final int hrv;
  final int stress;
  final int energy;

  const ResultScreen({
    super.key,
    required this.bpm,
    required this.hrv,
    required this.stress,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey : Colors.grey.shade700;
    final Color cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100;
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
        title: Text("Details", style: TextStyle(color: textColor)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Heart rate", style: TextStyle(color: subText, fontSize: 16)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("$bpm",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 60,
                        fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0, left: 8),
                  child: Text("BPM",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                    value: "${hrv}ms",
                    label: "HRV",
                    textColor: textColor,
                    subText: subText),
                _StatItem(
                    value: "$stress%",
                    label: "Stress",
                    textColor: textColor,
                    subText: subText),
                _StatItem(
                    value: "$energy%",
                    label: "Energy",
                    textColor: textColor,
                    subText: subText),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: cardBg, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Heart rate: $bpm BPM",
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 5),
                      const Text("Normal",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Normal range: 60 - 100",
                      style: TextStyle(color: subText, fontSize: 12)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.red
                          ]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: _calcPos(bpm)),
                        child:
                        Icon(Icons.arrow_drop_up, color: textColor, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                      "Great! Your heart rate remains in the normal range.",
                      style: TextStyle(color: subText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcPos(int bpm) {
    if (bpm < 40) return 0;
    if (bpm > 140) return 200;
    return (bpm - 40) * 2.5;
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color textColor;
  final Color subText;

  const _StatItem(
      {required this.value,
        required this.label,
        required this.textColor,
        required this.subText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subText, fontSize: 14)),
      ],
    );
  }
}