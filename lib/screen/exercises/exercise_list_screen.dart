// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// // FIX: Import the controller file correctly
// // Since this file is deep in lib/screen/exercises/, we need to go up two levels (../../)
// import '../../controllers/exercise_list_controller.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // Import the controller we created
// import '../../controllers/exercise_list_controller.dart';
// import '../screen.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/exercise_list_controller.dart';
// import 'exercise_detail_screen.dart'; // Import your detail screen
//
// class ExerciseListScreen extends StatelessWidget {
//   const ExerciseListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final ExerciseListController controller = Get.put(ExerciseListController());
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Exercise Library", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator(color: Colors.red));
//         }
//
//         if (controller.exerciseList.isEmpty) {
//           return const Center(child: Text("No exercises found."));
//         }
//
//         return GridView.builder(
//           padding: const EdgeInsets.all(12),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.65, // Adjusts card height
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//           ),
//           itemCount: controller.exerciseList.length,
//           itemBuilder: (context, index) {
//             final ex = controller.exerciseList[index];
//
//             // 1. Safe Data Parsing
//             String name = ex['name'] ?? 'Unknown';
//             String target = ex['target'] ?? 'General';
//             String equipment = ex['equipment'] ?? 'Body Weight';
//             String difficulty = ex['difficulty'] ?? 'Beginner';
//             String gifUrl = ex['gifUrl'] ?? '';
//
//             // 2. Wrap in GestureDetector for navigation
//             return GestureDetector(
//               onTap: () {
//                 Get.to(() => ExerciseDetailScreen(exercise: ex));
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
//                   ],
//                 ),
//                 // 3. THIS CHILD WAS MISSING IN YOUR CODE!
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- IMAGE SECTION ---
//                     Expanded(
//                       flex: 3,
//                       child: ClipRRect(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                         child: gifUrl.isNotEmpty
//                             ? Image.network(
//                           gifUrl,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (ctx, child, progress) {
//                             if (progress == null) return child;
//                             return Container(
//                                 color: Colors.grey[100],
//                                 child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
//                             );
//                           },
//                           errorBuilder: (c, e, s) => Container(
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
//                           ),
//                         )
//                             : Container(
//                           color: Colors.grey[200],
//                           child: const Center(child: Icon(Icons.fitness_center, color: Colors.grey, size: 40)),
//                         ),
//                       ),
//                     ),
//
//                     // --- DETAILS SECTION ---
//                     Expanded(
//                       flex: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               name.toUpperCase(),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                             ),
//                             const SizedBox(height: 6),
//
//                             // Badges
//                             _buildBadge(target, Colors.blue.shade50, Colors.blue.shade700),
//                             const SizedBox(height: 4),
//                             _buildBadge(equipment, Colors.orange.shade50, Colors.orange.shade800),
//                             const SizedBox(height: 4),
//
//                             // Difficulty
//                             Row(
//                               children: [
//                                 Icon(Icons.bar_chart, size: 14, color: Colors.grey[600]),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     difficulty,
//                                     style: TextStyle(color: Colors.grey[700], fontSize: 11),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
//
//   // Helper widget to make colorful badges
//   Widget _buildBadge(String text, Color bgColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         text.toUpperCase(),
//         style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_list_controller.dart';
import 'exercise_detail_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_list_controller.dart';
import 'exercise_detail_screen.dart';
import 'exercise_detail_screen.dart'; // Make sure this import is correct
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_list_controller.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is present
    if (!Get.isRegistered<ExerciseListController>()) {
      Get.put(ExerciseListController());
    }
    final ExerciseListController controller = Get.find<ExerciseListController>();


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Exercise Library", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (controller.exerciseList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
                const SizedBox(height: 10),
                const Text("No exercises loaded."),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.loadData(),
                  child: const Text("Reload Data"),
                )
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70, // Adjusted aspect ratio slightly
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.exerciseList.length,
          itemBuilder: (context, index) {
            final ex = controller.exerciseList[index];

            // 1. Parse Basic Data
            String name = ex['name'] ?? 'Unknown';
            String target = "General";
            if (ex['primaryMuscles'] != null && (ex['primaryMuscles'] as List).isNotEmpty) {
              target = ex['primaryMuscles'][0];
            }
            String difficulty = ex['level'] ?? 'Beginner';


            // ============================================================
            // 2. PROCESS MULTIPLE IMAGES
            // ============================================================
            List<String> allImageUrls = [];
            String thumbnail = '';

            if (ex['images'] != null && (ex['images'] as List).isNotEmpty) {
              // Convert ALL paths to full URLs
              allImageUrls = (ex['images'] as List).map((path) {
                return "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$path";
              }).toList().cast<String>();

              // Use the first one for the grid thumbnail
              thumbnail = allImageUrls[0];
            }
            // ============================================================


            return GestureDetector(
              onTap: () {
                // Prepare data for the detail screen
                Map<String, dynamic> fixedEx = Map.from(ex);
                // PASS THE FULL LIST OF URLS
                fixedEx['imageUrls'] = allImageUrls;
                // Standardize other fields
                fixedEx['target'] = target;
                fixedEx['difficulty'] = difficulty;

                Get.to(() => ExerciseDetailScreen(exercise: fixedEx));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        // Show only the thumbnail in the grid
                        child: thumbnail.isNotEmpty
                            ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(color: Colors.grey[100]);
                          },
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.fitness_center, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              target.toUpperCase(),
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}