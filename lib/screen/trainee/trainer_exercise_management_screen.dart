// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
//
// import '../../controllers/controller.dart';
// import '../../controllers/exercise_visibility_controller.dart';
//
//
// class TrainerExerciseManagementScreen extends StatelessWidget {
//   const TrainerExerciseManagementScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final WgerController wgerController = Get.put(WgerController());
//     final ExerciseVisibilityController visController = Get.put(ExerciseVisibilityController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Manage Exercise Visibility"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Obx(() {
//         if (wgerController.isLoading.value || visController.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: wgerController.exerciseList.length,
//           itemBuilder: (context, index) {
//             var exercise = wgerController.exerciseList[index];
//             String exerciseId = exercise['id'].toString();
//
//             return Card(
//               elevation: 2,
//               margin: const EdgeInsets.only(bottom: 12),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: ExpansionTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blue.shade50,
//                   child: const Icon(Icons.fitness_center, color: Colors.blue),
//                 ),
//                 title: Text(
//                   exercise['name'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(exercise['category']),
//                 children: [
//                   const Divider(),
//
//                   // 1. Header
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       "Select students to HIDE this exercise from:",
//                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//                     ),
//                   ),
//
//                   // 2. Student List
//                   if (visController.myStudents.isEmpty)
//                     const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text("No students found.", style: TextStyle(color: Colors.grey)),
//                     )
//                   else
//                     ...visController.myStudents.map((student) {
//
//                       // *** FIX IS HERE: USE STREAMBUILDER ***
//                       return StreamBuilder<bool>(
//                         stream: visController.isExerciseHiddenStream(
//                             exerciseId,
//                             student['uid']
//                         ),
//                         initialData: false, // Default value while loading
//                         builder: (context, snapshot) {
//                           bool isHidden = snapshot.data ?? false;
//
//                           return CheckboxListTile(
//                             title: Text(student['name']),
//                             subtitle: Text(student['email']),
//                             value: isHidden,
//                             activeColor: Colors.red, // Red means "Hidden"
//                             onChanged: (bool? value) {
//                               // Just trigger the update.
//                               // The StreamBuilder will handle the UI refresh automatically!
//                               visController.toggleExerciseForUser(
//                                 exerciseId,
//                                 exercise['name'],
//                                 student['uid'],
//                               );
//                             },
//                           );
//                         },
//                       );
//                     }).toList(),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }