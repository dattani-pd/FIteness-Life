// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// import '../../controllers/controller.dart'; // Add intl to pubspec.yaml for date formatting
//
// class SleepTrackerScreen extends StatelessWidget {
//   const SleepTrackerScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(SleepController());
//     final bool isDark = Get.isDarkMode;
//     final Color textColor = isDark ? Colors.white : Colors.black;
//     final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
//       appBar: AppBar(
//         title: Text("Sleep Tracker", style: TextStyle(color: textColor)),
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: textColor),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             // --- INPUT CARD ---
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: cardBg,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//               ),
//               child: Column(
//                 children: [
//                   const Text("Log Last Night's Sleep", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildTimePicker(context, controller, "Bed Time", true, isDark),
//                       const Icon(Icons.arrow_forward, color: Colors.grey),
//                       _buildTimePicker(context, controller, "Wake Time", false, isDark),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => controller.saveSleepLog(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.indigoAccent,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text("Save Sleep Log", style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
//             ),
//             const SizedBox(height: 10),
//
//             // --- HISTORY LIST ---
//             Expanded(
//               child: Obx(() {
//                 if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
//                 if (controller.sleepHistory.isEmpty) {
//                   return Center(child: Text("No sleep logs yet", style: TextStyle(color: Colors.grey[600])));
//                 }
//
//                 return ListView.separated(
//                   itemCount: controller.sleepHistory.length,
//                   separatorBuilder: (ctx, i) => const SizedBox(height: 10),
//                   itemBuilder: (context, index) {
//                     final log = controller.sleepHistory[index];
//                     return Container(
//                       padding: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: cardBg,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
//                             child: const Icon(Icons.bed, color: Colors.indigo),
//                           ),
//                           const SizedBox(width: 15),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(DateFormat('MMM dd, yyyy').format(log.date), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
//                                 Text(
//                                   "${DateFormat('hh:mm a').format(log.bedTime)} - ${DateFormat('hh:mm a').format(log.wakeTime)}",
//                                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             log.formattedDuration,
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigoAccent),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimePicker(BuildContext context, SleepController controller, String label, bool isBedTime, bool isDark) {
//     return Column(
//       children: [
//         Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         const SizedBox(height: 5),
//         InkWell(
//           onTap: () => controller.pickTime(context, isBedTime),
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.withOpacity(0.3)),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Obx(() {
//               final time = isBedTime ? controller.selectedBedTime.value : controller.selectedWakeTime.value;
//               return Text(
//                 time.format(context),
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }