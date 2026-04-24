import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../constant/constant.dart';
import '../../controllers/controller.dart';
import '../../controllers/exercise_visibility_controller.dart' hide MuscleWikiController;
import '../../controllers/muscle_wiki_controller.dart' hide MuscleWikiController;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../model/model.dart';
import 'package:fitness_life/services/woocommerce_api.dart';

// ==============================================================================
// MUSCLE WIKI PRO SCREEN - CLEAN VERSION
/// ==============================================================================
// class MuscleWikiProScreen extends StatelessWidget {
//   static const pageId = "/MuscleWikiProScreen";
//   const MuscleWikiProScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final MuscleWikiController controller = Get.put(MuscleWikiController());
//     final HomeController homeController = Get.find<HomeController>();
//     final ExerciseVisibilityController visController = Get.put(ExerciseVisibilityController());
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("WorkOut"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.list_alt_rounded),
//             tooltip: 'Workout Plans',
//             onPressed: () {
//               Get.to(() => const WorkoutPlansListScreen());
//             },
//           ),
//           Obx(() {
//             // 1. Check if the user role is 'user'. If so, hide the button.
//             // You can also use: if (homeController.userRole.value != 'trainer' && homeController.userRole.value != 'admin')
//             if (homeController.userRole.value == 'user') {
//               return const SizedBox.shrink();
//             }
//
//             // 2. Otherwise, show the Filter Button
//             return IconButton(
//               icon: Badge(
//                 isLabelVisible: controller.hasActiveFilters(),
//                 backgroundColor: Colors.red,
//                 label: Text('${controller.getActiveFilterCount()}'),
//                 child: const Icon(Icons.filter_list),
//               ),
//               onPressed: () => _showFilterBottomSheet(context, controller),
//             );
//           }),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // ==========================================
//           // COMPACT FILTER CHIPS
//           // ==========================================
//           Obx(() {
//             if (!controller.hasActiveFilters()) return const SizedBox.shrink();
//             return Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
//               ),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   if (controller.selectedCategory.value.name != "all")
//                     _buildFilterChip(
//                       controller.selectedCategory.value.displayName,
//                           () {
//                         controller.selectedCategory.value = controller.categoryList.first;
//                         controller.fetchExercises(reset: true);
//                       },
//                     ),
//                   if (controller.selectedGender.value != "Both")
//                     _buildFilterChip(
//                       controller.selectedGender.value,
//                           () {
//                         controller.selectedGender.value = "Both";
//                         controller.fetchExercises(reset: true);
//                       },
//                     ),
//                   if (controller.selectedDifficulty.value != "All Levels")
//                     _buildFilterChip(
//                       controller.selectedDifficulty.value,
//                           () {
//                         controller.selectedDifficulty.value = "All Levels";
//                         controller.fetchExercises(reset: true);
//                       },
//                     ),
//                   InkWell(
//                     onTap: () => controller.clearFilters(),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.red.shade300),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.clear_all, size: 14, color: Colors.red.shade700),
//                           const SizedBox(width: 4),
//                           Text(
//                             "Clear All",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.red.shade700,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//
//           // ==========================================
//           // EXERCISE GRID
//           // ==========================================
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value && controller.exercises.isEmpty) {
//                 return _buildShimmerGrid(screenWidth);
//               }
//
//               final displayList = controller.visibleExercises;
//               if (displayList.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade300),
//                       const SizedBox(height: 16),
//                       const Text(
//                         "No exercises found",
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       TextButton.icon(
//                         onPressed: () => _showFilterBottomSheet(context, controller),
//                         icon: const Icon(Icons.filter_list),
//                         label: const Text("Adjust Filters"),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return RefreshIndicator(
//                 onRefresh: () async => controller.fetchExercises(reset: true),
//                 child: GridView.builder(
//                   controller: controller.scrollController,
//                   padding: const EdgeInsets.all(12),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: screenWidth > 600 ? 3 : 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 0.70,
//                   ),
//                   itemCount: displayList.length + (controller.isLoading.value ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == displayList.length) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     final ex = displayList[index];
//                     bool isHidden = controller.isHiddenReversed(ex.id);
//                     bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' ||
//                         homeController.userRole.value == 'admin';
//                     String difficulty = ex.difficulty;
//                     String target = ex.targetMuscles.isNotEmpty ? ex.targetMuscles.first : "";
//
//                     return Card(
//                       margin: EdgeInsets.zero,
//                       color: (isTrainerOrAdmin && !isHidden) ? Colors.green.shade100 :
//                       Colors.white,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       elevation: 2,
//                       clipBehavior: Clip.antiAlias,
//                       child: Stack(
//                         children: [
//                           InkWell(
//                             onTap: () => Get.to(() => ChewieDetailScreen(
//                               exercise: ex,
//                               apiKey: controller.apiKey,
//                               genderPreference: controller.selectedGender.value,
//                             )),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       CachedNetworkImage(
//                                         imageUrl: ex.getCategoryImage(),
//                                         fit: BoxFit.cover,
//                                         placeholder: (context, url) => Container(
//                                           color: Colors.grey.shade200,
//                                           child: const Center(
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                               valueColor: AlwaysStoppedAnimation<Color>(
//                                                 Color(0xFF1A237E),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         errorWidget: (context, url, error) {
//                                           print("❌ Image load failed: $url");
//                                           return _buildPlaceholder(ex.name);
//                                         },
//                                         memCacheWidth: 600,
//                                         maxHeightDiskCache: 600,
//                                       ),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             begin: Alignment.topCenter,
//                                             end: Alignment.bottomCenter,
//                                             colors: [
//                                               Colors.transparent,
//                                               Colors.black.withOpacity(0.1),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         top: 8,
//                                         right: 8,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                                           decoration: BoxDecoration(
//                                             color: Colors.black.withOpacity(0.6),
//                                             borderRadius: BorderRadius.circular(4),
//                                           ),
//                                           child: Text(
//                                             ex.category.toUpperCase(),
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 8,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           ex.name,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             // decoration: (isTrainer && isHidden)
//                                             //     ? TextDecoration.lineThrough
//                                             //     : null,
//                                              color:
//                                              // (isTrainer && isHidden)
//                                              //     ? Colors.red:
//                                              Colors.black87,
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Wrap(
//                                           spacing: 4,
//                                           runSpacing: 4,
//                                           children: [
//                                             if (ex.category.isNotEmpty)
//                                               _buildGridTag(
//                                                 ex.category,
//                                                 Colors.blue.shade50,
//                                                 Colors.blue.shade700,
//                                               ),
//                                             if (difficulty.isNotEmpty)
//                                               _buildGridTag(
//                                                 difficulty,
//                                                 Colors.orange.shade50,
//                                                 Colors.orange.shade800,
//                                               ),
//                                             if (ex.category.isEmpty &&
//                                                 difficulty.isEmpty &&
//                                                 target.isNotEmpty)
//                                               _buildGridTag(
//                                                 target,
//                                                 Colors.green.shade50,
//                                                 Colors.green.shade800,
//                                               ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (isTrainerOrAdmin)
//                             Positioned(
//                               top: 8,
//                               left: 8,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   print("🔵 Three dots tapped for: ${ex.name}");
//                                   _showExerciseOptionsSheet(context, controller, visController, ex);
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.7),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: const Icon(
//                                     Icons.more_vert,
//                                     color: Colors.white,
//                                     size: 18,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==========================================
//   // FILTER BOTTOM SHEET
//   // ==========================================
//   void _showFilterBottomSheet(BuildContext context, MuscleWikiController controller) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: true,
//       enableDrag: true,
//       builder: (context) => Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.85,
//         ),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12, bottom: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const SizedBox(width: 48),
//                   const Text(
//                     "Filter Exercises",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(),
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Equipment Category",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Obx(() => Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<CategoryItem>(
//                           value: controller.selectedCategory.value,
//                           isExpanded: true,
//                           icon: const Icon(Icons.keyboard_arrow_down),
//                           items: controller.categoryList
//                               .map((item) => DropdownMenuItem(
//                             value: item,
//                             child: Text(item.displayName),
//                           ))
//                               .toList(),
//                           onChanged: (newValue) {
//                             if (newValue != null) {
//                               controller.selectedCategory.value = newValue;
//                             }
//                           },
//                         ),
//                       ),
//                     )),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Video Gender Preference",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Obx(() => Wrap(
//                       spacing: 8,
//                       children: controller.genderList.map((gender) {
//                         bool isSelected = controller.selectedGender.value == gender;
//                         return ChoiceChip(
//                           label: Text(gender),
//                           selected: isSelected,
//                           onSelected: (selected) {
//                             if (selected) {
//                               controller.selectedGender.value = gender;
//                             }
//                           },
//                           selectedColor: const Color(0xFF1A237E),
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         );
//                       }).toList(),
//                     )),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Difficulty Level",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Obx(() => Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: controller.difficultyList.map((difficulty) {
//                         bool isSelected = controller.selectedDifficulty.value == difficulty;
//                         return ChoiceChip(
//                           label: Text(difficulty),
//                           selected: isSelected,
//                           onSelected: (selected) {
//                             if (selected) {
//                               controller.selectedDifficulty.value = difficulty;
//                             }
//                           },
//                           selectedColor: const Color(0xFF1A237E),
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         );
//                       }).toList(),
//                     )),
//                     const SizedBox(height: 30),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               controller.clearFilters();
//                               Navigator.pop(context);
//                             },
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               side: BorderSide(color: Colors.grey.shade300),
//                             ),
//                             child: const Text(
//                               "Clear Filters",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               controller.fetchExercises(reset: true);
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF1A237E),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: const Text(
//                               "Apply Filters",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showExerciseOptionsSheet(
//       BuildContext context,
//       MuscleWikiController controller,
//       ExerciseVisibilityController visController,
//       Exercise exercise,
//       ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle bar
//             Container(
//               margin: const EdgeInsets.only(top: 12, bottom: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//
//             // Exercise name
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 exercise.name,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const Divider(),
//
//             // ✅ ONLY THIS OPTION - Add to Workout Plan
//             ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.add_circle_outline, color: Colors.blue.shade700, size: 24),
//               ),
//               title: const Text(
//                 "Add to Workout Plan",
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               subtitle: Text(
//                 "Assign this exercise to a workout plan",
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 _showWorkoutPlanSelectionSheet(context, exercise);
//               },
//             ),
//
//             const Divider(),
//
//             // Cancel
//             ListTile(
//               leading: const Icon(Icons.close, color: Colors.grey),
//               title: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500)),
//               onTap: () => Navigator.pop(ctx),
//             ),
//
//             SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showWorkoutPlanSelectionSheet(BuildContext context, Exercise exercise) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _WorkoutPlanSelectionContent(exercise: exercise),
//     );
//   }
//
//
//   // ==========================================
//   // STUDENT VISIBILITY SHEET
//   // ==========================================
//   void _showStudentVisibilitySheet(
//       BuildContext context,
//       ExerciseVisibilityController visController,
//       Exercise exercise,
//       ) {
//     String exerciseId = exercise.id.toString();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _StudentVisibilityContent(
//         exerciseId: exerciseId,
//         exerciseName: exercise.name,
//         visController: visController,
//       ),
//     );
//   }
//
//   // ==========================================
//   // HELPER WIDGETS
//   // ==========================================
//   Widget _buildFilterChip(String label, VoidCallback onDelete) {
//     return Container(
//       padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A237E).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Flexible(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF1A237E),
//                 fontWeight: FontWeight.w600,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           const SizedBox(width: 4),
//           InkWell(
//             onTap: onDelete,
//             child: const Icon(
//               Icons.close,
//               size: 16,
//               color: Color(0xFF1A237E),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGridTag(String text, Color bg, Color textCol) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: bg.withOpacity(0.5)),
//       ),
//       child: Text(
//         text.toUpperCase(),
//         style: TextStyle(
//           color: textCol,
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholder(String name) {
//     final colors = [
//       const Color(0xFFFFF9C4),
//       const Color(0xFFF8BBD0),
//       const Color(0xFFE1BEE7),
//       const Color(0xFFC8E6C9),
//       const Color(0xFFB2DFDB),
//     ];
//     final color = colors[name.length % colors.length];
//     return Container(
//       color: color,
//       child: Center(
//         child: Text(
//           name.isNotEmpty ? name[0].toUpperCase() : "?",
//           style: const TextStyle(
//             fontSize: 50,
//             fontWeight: FontWeight.bold,
//             color: Colors.black26,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmerGrid(double screenWidth) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: screenWidth > 600 ? 3 : 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 0.70,
//       ),
//       itemCount: 8,
//       itemBuilder: (ctx, i) => Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MuscleWikiProScreen extends StatelessWidget {
  static const pageId = "/MuscleWikiProScreen";
  const MuscleWikiProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MuscleWikiController controller = Get.put(MuscleWikiController());
    final HomeController homeController = Get.find<HomeController>();
    final ExerciseVisibilityController visController = Get.put(ExerciseVisibilityController());
    final screenWidth = MediaQuery.of(context).size.width;

    // 🎨 Theme Colors
    final bool isDark = Get.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.black87;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color filterBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor, // ✅ Dynamic BG
      appBar: AppBar(
        title: Text("WorkOut", style: TextStyle(color: textColor)),
        backgroundColor: bgColor, // ✅ Dynamic AppBar BG
        foregroundColor: textColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt_rounded, color: iconColor),
            tooltip: 'Workout Plans',
            onPressed: () {
              Get.to(() => const WorkoutPlansListScreen());
            },
          ),
          Obx(() {
            if (homeController.userRole.value == 'user') {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Badge(
                isLabelVisible: controller.hasActiveFilters(),
                backgroundColor: Colors.green,
                label: Text('${controller.getActiveFilterCount()}'),
                child: Icon(Icons.filter_list, color: iconColor),
              ),
              onPressed: () => _showFilterBottomSheet(context, controller),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ==========================================
          // COMPACT FILTER CHIPS
          // ==========================================
          Obx(() {
            if (!controller.hasActiveFilters()) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: filterBg, // ✅ Dynamic Filter BG
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (controller.selectedCategory.value.name != "all")
                    _buildFilterChip(
                        controller.selectedCategory.value.displayName,
                            () {
                          controller.selectedCategory.value = controller.categoryList.first;
                          controller.applyFiltersLocally();
                        },
                        isDark
                    ),
                  if (controller.selectedGender.value != "Both")
                    _buildFilterChip(
                        controller.selectedGender.value,
                            () {
                          controller.selectedGender.value = "Both";
                          controller.applyFiltersLocally();
                        },
                        isDark
                    ),
                  if (controller.selectedDifficulty.value != "All Levels")
                    _buildFilterChip(
                        controller.selectedDifficulty.value,
                            () {
                          controller.selectedDifficulty.value = "All Levels";
                          controller.applyFiltersLocally();
                        },
                        isDark
                    ),
                  InkWell(
                    onTap: () => controller.clearFilters(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_all, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            "Clear All",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ==========================================
          // EXERCISE GRID
          // ==========================================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.exercises.isEmpty) {
                return _buildShimmerGrid(screenWidth, isDark);
              }

              final displayList = controller.visibleExercises;
              if (displayList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No exercises found",
                        style: TextStyle(color: subTextColor, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showFilterBottomSheet(context, controller),
                        icon: const Icon(Icons.filter_list),
                        label: const Text("Adjust Filters"),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => controller.refresh(),
                child: GridView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: displayList.length + (controller.isLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayList.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ex = displayList[index];
                    bool isHidden = controller.isHiddenReversed(ex.id);
                    bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' ||
                        homeController.userRole.value == 'admin';
                    String difficulty = ex.difficulty;
                    String target = ex.targetMuscles.isNotEmpty ? ex.targetMuscles.first : "";

                    // Dynamic Card Color based on Role/Theme
                    Color cardBg = cardColor;
                    if (isTrainerOrAdmin && !isHidden) {
                      cardBg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade100;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      color: cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: () => Get.to(() => ChewieDetailScreen(
                              exercise: ex,
                              //apiKey: controller.apiKey,
                              genderPreference: controller.selectedGender.value,
                            )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: (ex.getCategoryImage().isEmpty)
                                            ? "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600"
                                            : ex.getCategoryImage(),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          return _buildPlaceholder(ex.name);
                                        },
                                        memCacheWidth: 600,
                                        maxHeightDiskCache: 600,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.4), // Darker gradient
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ex.category.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          ex.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textColor, // ✅ Dynamic Text
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: [
                                            if (ex.category.isNotEmpty)
                                              _buildGridTag(
                                                ex.category,
                                                isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                                                isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                                              ),
                                            if (difficulty.isNotEmpty)
                                              _buildGridTag(
                                                difficulty,
                                                isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade50,
                                                isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                                              ),
                                            if (ex.category.isEmpty && difficulty.isEmpty && target.isNotEmpty)
                                              _buildGridTag(
                                                target,
                                                isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                                                isDark ? Colors.green.shade200 : Colors.green.shade800,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isTrainerOrAdmin)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: GestureDetector(
                                onTap: () {
                                  _showExerciseOptionsSheet(context, controller, visController, ex);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS (Updated)
  // ==========================================
  Widget _buildFilterChip(String label, VoidCallback onDelete, bool isDark) {
    final Color chipColor = isDark ? Colors.blue.shade900.withOpacity(0.3) : const Color(0xFF1A237E).withOpacity(0.1);
    final Color textColor = isDark ? Colors.blue.shade100 : const Color(0xFF1A237E);

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bg.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    final colors = [
      const Color(0xFFFFF9C4), const Color(0xFFF8BBD0), const Color(0xFFE1BEE7),
      const Color(0xFFC8E6C9), const Color(0xFFB2DFDB),
    ];
    final color = colors[name.length % colors.length];
    return Container(
      color: color,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black26),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(double screenWidth, bool isDark) {
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemCount: 10,
        itemBuilder: (ctx, i) {
          return Container(
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                ),
                // Title & subtitle placeholders
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // EXERCISE OPTIONS BOTTOM SHEET (Updated)
  // ==========================================
  void _showExerciseOptionsSheet(BuildContext context, MuscleWikiController controller, ExerciseVisibilityController visController, Exercise exercise) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  exercise.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(color: Colors.grey.shade800),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_circle_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 24),
                ),
                title: Text("Add to Workout Plan", style: TextStyle(fontWeight: FontWeight.w600, color: text)),
                subtitle: Text("Assign this exercise to a workout plan", style: TextStyle(fontSize: 12, color: subText)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
                onTap: () {
                  Navigator.pop(ctx);
                  _showWorkoutPlanSelectionSheet(context, exercise);
                },
              ),
              Divider(color: Colors.grey.shade800),
              ListTile(
                leading: Icon(Icons.close, color: subText),
                title: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, color: text)),
                onTap: () => Navigator.pop(ctx),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FILTER BOTTOM SHEET (Updated)
  // ==========================================
// ==========================================
  // FILTER BOTTOM SHEET (Updated with Difficulty)
  // ==========================================
  void _showFilterBottomSheet(BuildContext context, MuscleWikiController controller) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black87;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    // ✅ The specific difficulty list you requested
    final List<String> difficultyOptions = [
      "All Levels",
      "Beginner",
      "Novice",
      "Intermediate",
      "Advanced"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text("Filter Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  IconButton(icon: Icon(Icons.close, color: text), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade800),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CATEGORY DROPDOWN
                    Text("Equipment Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: text)),
                    const SizedBox(height: 12),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputFill,
                        border: Border.all(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CategoryItem>(
                          dropdownColor: bg,
                          style: TextStyle(color: text),
                          value: controller.selectedCategory.value,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: text),
                          items: controller.categoryList.map((item) => DropdownMenuItem(value: item, child: Text(item.displayName))).toList(),
                          onChanged: (newValue) { if (newValue != null) controller.selectedCategory.value = newValue; },
                        ),
                      ),
                    )),

                    const SizedBox(height: 20),

                    // 2. GENDER CHIPS
                    Text("Video Gender Preference", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: text)),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      children: controller.genderList.map((gender) {
                        bool isSelected = controller.selectedGender.value == gender;
                        return ChoiceChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected)
                              controller.selectedGender.value = gender;
                            },
                          selectedColor: const Color(0xFF8B0000),
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : text, fontWeight: FontWeight.w500),
                        );
                      }).toList(),
                    )),

                    const SizedBox(height: 20),

                    // 3. ✅ RESTORED DIFFICULTY CHIPS
                    Text("Difficulty Level", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: text)),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: difficultyOptions.map((difficulty) {
                        bool isSelected = controller.selectedDifficulty.value == difficulty;
                        return ChoiceChip(
                          label: Text(difficulty),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) controller.selectedDifficulty.value = difficulty;
                          },
                          selectedColor: const Color(0xFF8B0000),
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : text, fontWeight: FontWeight.w500),
                        );
                      }).toList(),
                    )),

                    const SizedBox(height: 30),

                    // ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () { controller.clearFilters(); Navigator.pop(context); },
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade600)),
                            child: Text("Clear Filters", style: TextStyle(fontWeight: FontWeight.bold, color: text)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () { controller.applyFiltersLocally(); Navigator.pop(context); },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showWorkoutPlanSelectionSheet(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WorkoutPlanSelectionContent(exercise: exercise),
    );
  }
}

/// ==============================================================================
// STUDENT VISIBILITY CONTENT WIDGET
// ==============================================================================
class _StudentVisibilityContent extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final ExerciseVisibilityController visController;

  const _StudentVisibilityContent({
    required this.exerciseId,
    required this.exerciseName,
    required this.visController,
  });

  @override
  State<_StudentVisibilityContent> createState() => _StudentVisibilityContentState();
}

class _StudentVisibilityContentState extends State<_StudentVisibilityContent> {
  Map<String, bool> selectedStudents = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    for (var student in widget.visController.myStudents) {
      String studentUid = student['uid'] ?? '';
      bool isVisible = await widget.visController
          .isExerciseVisibleStream(widget.exerciseId, studentUid)
          .first;
      selectedStudents[studentUid] = isVisible;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.visibility, color: Colors.green),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Show to Students",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.exerciseName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.visController.myStudents.isEmpty
                ? const Center(
              child: Text(
                "No students found.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: widget.visController.myStudents.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                var student = widget.visController.myStudents[index];
                String studentUid = student['uid'] ?? '';
                String studentName = student['name'] ?? 'Unknown';
                String studentEmail = student['email'] ?? '';
                bool isVisible = selectedStudents[studentUid] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    value: isVisible,
                    onChanged: (val) {
                      setState(() {
                        selectedStudents[studentUid] = val ?? false;
                      });
                    },
                    activeColor: Colors.green,
                    title: Text(
                      studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: studentEmail.isNotEmpty
                        ? Text(
                      studentEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                        : null,
                    secondary: CircleAvatar(
                      backgroundColor: isVisible
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: isVisible ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Check students who should see this exercise",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.of(context).padding.bottom + 16
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () async {
                      setState(() => isLoading = true);

                      for (var entry in selectedStudents.entries) {
                        String studentUid = entry.key;
                        bool shouldBeVisible = entry.value;

                        bool currentlyVisible = await widget.visController
                            .isExerciseVisibleStream(widget.exerciseId, studentUid)
                            .first;

                        if (currentlyVisible != shouldBeVisible) {
                          await widget.visController.setExerciseVisibilityForUser(
                            widget.exerciseId,
                            widget.exerciseName,
                            studentUid,
                            shouldBeVisible,
                          );
                        }
                      }

                      if (mounted) {
                        Get.snackbar(
                          "Saved",
                          "Student access updated successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// CONTROLLER EXTENSION (Keep your existing extension methods)
// ==============================================================================
extension MuscleWikiControllerExtension on MuscleWikiController {
  bool hasActiveFilters() {
    return selectedCategory.value.name != "all" ||
        selectedGender.value != "Both" ||
        selectedDifficulty.value != "All Levels";
  }

  int getActiveFilterCount() {
    int count = 0;
    if (selectedCategory.value.name != "all") count++;
    if (selectedGender.value != "Both") count++;
    if (selectedDifficulty.value != "All Levels") count++;
    return count;
  }
}




class _WorkoutPlanSelectionContent extends StatefulWidget {
  final Exercise exercise;

  const _WorkoutPlanSelectionContent({required this.exercise});

  @override
  State<_WorkoutPlanSelectionContent> createState() => _WorkoutPlanSelectionContentState();
}

// ==========================================
// COMPLETE FIX - Both methods fixed
// ==========================================

class _WorkoutPlanSelectionContentState extends State<_WorkoutPlanSelectionContent> {
  List<WorkoutPlan> workoutPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlans();
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        print('❌ No user logged in');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('🔍 Loading workout plans for user: $currentUid');

      final snapshot = await FirebaseFirestore.instance
          .collection('workout_plans')
          .where('createdBy', isEqualTo: currentUid)
          .orderBy('createdAt', descending: true)
          .get();

      workoutPlans = snapshot.docs.map((doc) {
        return WorkoutPlan.fromFirestore(doc.data(), doc.id);
      }).toList();

      print('✅ Loaded ${workoutPlans.length} workout plans');
    } catch (e) {
      print('❌ Error loading workout plans: $e');
      print('   Error details: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ✅ FIXED: Add exercise to existing plan
  Future<void> _addExerciseToPlan(WorkoutPlan plan) async {
    try {
      print('🔄 Adding ${widget.exercise.name} to plan ${plan.name}');

      final planDoc = await FirebaseFirestore.instance
          .collection('workout_plans')
          .doc(plan.id)
          .get();

      if (!planDoc.exists) {
        print('❌ Plan document does not exist');
        return;
      }

      final planData = planDoc.data()!;
      List<dynamic> exercisesData = planData['exercises'] ?? [];

      // Check if exercise already exists
      bool alreadyExists = exercisesData.any((ex) =>
      ex['exerciseId'] == widget.exercise.id.toString()
      );

      if (alreadyExists) {
        Navigator.pop(context);
        Get.snackbar(
          'Already Added',
          '${widget.exercise.name} is already in ${plan.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // ✅ FIX: Use DateTime.now() instead of FieldValue.serverTimestamp()
      final now = DateTime.now().toIso8601String();

      // Add exercise
      exercisesData.add({
        'exerciseId': widget.exercise.id.toString(),
        'exerciseName': widget.exercise.name,
        'category': widget.exercise.category,
        'difficulty': widget.exercise.difficulty,
        'sets': 3,
        'reps': 12,
        'rest': 60,
        'addedAt': now, // ✅ FIXED: Use DateTime string
      });

      await FirebaseFirestore.instance
          .collection('workout_plans')
          .doc(plan.id)
          .update({
        'exercises': exercisesData,
        'updatedAt': FieldValue.serverTimestamp(), // ✅ OK: Outside array
      });

      print('✅ Successfully added exercise to plan');

      Navigator.pop(context);

      Get.snackbar(
        'Added',
        '${widget.exercise.name} added to ${plan.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error adding exercise to plan: $e');
      print('   Error details: ${e.toString()}');

      Get.snackbar(
        'Error',
        'Failed to add exercise: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add to Workout Plan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.exercise.name,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Plans List
          Flexible(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : workoutPlans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              shrinkWrap: true,
              itemCount: workoutPlans.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final plan = workoutPlans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fitness_center, color: Colors.blue.shade700, size: 24),
                    ),
                    title: Text(
                      plan.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${plan.exercises.length} exercises',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.add_circle, color: Colors.blue),
                    onTap: () => _addExerciseToPlan(plan),
                  ),
                );
              },
            ),
          ),

          // Create New Plan Button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreatePlanDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Plan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.blue.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Workout Plans Yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first workout plan to add exercises",
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showCreatePlanDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Create new plan
  void _showCreatePlanDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController(); // 🆕
    final TextEditingController durationController = TextEditingController(); // 🆕

    // 🆕 Dropdown State
    final RxString selectedUnit = 'Weeks'.obs;
    final List<String> timeUnits = ['Days', 'Weeks', 'Months', 'Years'];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.fitness_center, color: Colors.blue.shade700, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Create Workout Plan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Plan Name',
                    hintText: 'e.g., Upper Body, Leg Day, Full Body',
                    prefixIcon: const Icon(Icons.edit_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Price Input (🆕)
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: '0 for free',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Duration Input (🆕)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          hintText: 'e.g. 4',
                          prefixIcon: const Icon(Icons.timer_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey)
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit.value,
                            isExpanded: true,
                            items: timeUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if(val != null) selectedUnit.value = val;
                            },
                          ),
                        ),
                      )),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final price = priceController.text.trim();
                          final duration = durationController.text.trim();

                          if (name.isEmpty) return;
                          Get.back(); // Dialog બંધ કરો

                          final currentUid = FirebaseAuth.instance.currentUser?.uid;
                          if (currentUid == null) return;

                          // 1️⃣ આ સ્ટેટિક ઈમેજ URL છે જે Web અને App બંનેમાં જશે
                          const String defaultWebImg = "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=500";

                          // 2️⃣ Firestore માં સેવ (App માટે)
                          final ref = FirebaseFirestore.instance.collection('workout_plans').doc();
                          await ref.set({
                            'name': name,
                            'price': price.isEmpty ? '0' : price,
                            'duration': duration.isEmpty ? '0' : duration,
                            'durationUnit': selectedUnit.value,
                            'imageUrl': defaultWebImg, // ✅ Firestore માં આ URL જશે
                            'createdBy': currentUid,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          // Create workout_plan_assignments doc so plan can be assigned to users
                          await FirebaseFirestore.instance.collection('workout_plan_assignments').doc(ref.id).set({
                            'planId': ref.id,
                            'planName': name,
                            'assignedUsers': [],
                          }, SetOptions(merge: true));

                          // 3️⃣ Web (WooCommerce) પર સિંક (Web માટે)
                          // 🚨 ખાસ ચેક કરો કે syncPlanToWebsite માં 'imageUrl' પેરામીટર પાસ થાય છે
                          WooCommerceSyncResult syncResult = await syncPlanToWebsite(
                            title: name,
                            price: price.isEmpty ? '0' : price,
                            description: 'Professional Workout Plan: $name',
                            imageUrl: defaultWebImg, // ✅ આ લાઈન Web પર ફોટો લાવશે!
                          );

                          if (syncResult.success && syncResult.productId != null) {
                            await ref.update({'wooProductId': syncResult.productId});
                          }

                          _loadWorkoutPlans();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Create & Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// ==============================================================================
// WORKOUT PLANS LIST SCREEN (Themed)
// ==============================================================================

class WorkoutPlansListScreen extends StatefulWidget {
  const WorkoutPlansListScreen({super.key});

  @override
  State<WorkoutPlansListScreen> createState() => _WorkoutPlansListScreenState();
}

class _WorkoutPlansListScreenState extends State<WorkoutPlansListScreen> {
  List<WorkoutPlan> workoutPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlans();
    _listenToWorkoutPlans();
  }

  // ... (Keep existing _loadWorkoutPlans and _listenToWorkoutPlans methods)
  // Included below for completeness but logic is unchanged
  Future<void> _loadWorkoutPlans() async {
    setState(() => isLoading = true);

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final currentRole = AppConstants.role;

      if (currentUid == null) {
        setState(() => isLoading = false);
        return;
      }

      List<WorkoutPlan> loadedPlans = [];

      // --------------------------
      // 1. ADMIN LOGIC (View All)
      // --------------------------
      if (currentRole == 'admin') {
        final snapshot = await FirebaseFirestore.instance
            .collection('workout_plans')
            .orderBy('createdAt', descending: true)
            .get();

        loadedPlans = snapshot.docs
            .map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id))
            .toList();
      }

      // --------------------------
      // 2. TRAINER LOGIC (View Created By Me)
      // --------------------------
      else if (currentRole == 'trainer') {
        final snapshot = await FirebaseFirestore.instance
            .collection('workout_plans')
            .where('createdBy', isEqualTo: currentUid)
            .orderBy('createdAt', descending: true)
            .get();

        // 🔴 FIX: આ લાઈન તમારા જૂના કોડમાં મિસિંગ હતી
        loadedPlans = snapshot.docs
            .map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id))
            .toList();
      }

      // --------------------------
      // 3. USER LOGIC (Assigned + Free Plans)
      // --------------------------
      else {
        // Step A: Get Assigned Plans
        final assignmentsSnapshot = await FirebaseFirestore.instance
            .collection('workout_plan_assignments')
            .where('assignedUsers', arrayContains: currentUid)
            .get();

        Set<String> planIds = assignmentsSnapshot.docs.map((doc) => doc.id).toSet();

        // // Step B: Get "Free Plans" (Auto-assign)
        // final freeSnapshot = await FirebaseFirestore.instance
        //     .collection('workout_plans')
        //     .where('name', whereIn: ['free plan', 'Free Plan', 'Free plan', 'FREE PLAN', 'free'])
        //     .get();
        //
        // for (var doc in freeSnapshot.docs) {
        //   planIds.add(doc.id);
        // }

        // Step C: If no plans found, return empty
        if (planIds.isEmpty) {
          setState(() {
            workoutPlans = [];
            isLoading = false;
          });
          return;
        }

        // Step D: Fetch Plan Details (Chunked for >10 items)
        List<String> allIds = planIds.toList();
        for (var i = 0; i < allIds.length; i += 10) {
          var end = (i + 10 < allIds.length) ? i + 10 : allIds.length;
          var chunk = allIds.sublist(i, end);

          if (chunk.isNotEmpty) {
            final snap = await FirebaseFirestore.instance
                .collection('workout_plans')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

            loadedPlans.addAll(snap.docs.map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id)));
          }
        }
      }

      // --------------------------
      // 4. SORTING & STATE UPDATE
      // --------------------------
      // Sort by newest first (Created At)
      loadedPlans.sort((a, b) {
        // ✅ FIX: Explicit Casting added here
        Timestamp t1 = (a.createdAt is Timestamp) ? (a.createdAt as Timestamp) : Timestamp.now();
        Timestamp t2 = (b.createdAt is Timestamp) ? (b.createdAt as Timestamp) : Timestamp.now();

        return t2.compareTo(t1);
      });

      if (mounted) {
        setState(() {
          workoutPlans = loadedPlans;
        });
      }

      // Admin only: remove from website any Package product not linked to a Firebase workout_plan
      // Keep ALL wooProductIds from Firebase so 3 plans in Firebase = 3 products on web
      if (currentRole == 'admin' && loadedPlans.isNotEmpty) {
        final keepIds = loadedPlans.map((p) => p.wooProductId).whereType<String>().where((s) => s.trim().isNotEmpty).toList();
        final deleted = await removePackagesNotInFirestore(keepIds);
        if (mounted && deleted > 0) {
          Get.snackbar('Website cleaned', '$deleted old package(s) removed. Only Firebase plans show.', backgroundColor: Colors.blue, colorText: Colors.white, duration: const Duration(seconds: 4));
        }
        // Ensure every Firebase plan has a product on web (3 plans = 3 products on WooCommerce)
        int created = 0;
        for (final plan in loadedPlans) {
          if ((plan.wooProductId ?? '').trim().isNotEmpty) continue;
          final result = await syncPlanToWebsite(
            title: plan.name,
            price: plan.price,
            description: plan.description,
            imageUrl: (plan.imageUrl != null && plan.imageUrl!.trim().isNotEmpty) ? plan.imageUrl : null,
            wooProductId: null,
            forceCreate: true, // create a new product per plan so 3 plans = 3 products on web
          );
          if (result.success && result.productId != null) {
            await FirebaseFirestore.instance.collection('workout_plans').doc(plan.id).update({'wooProductId': result.productId});
            created++;
          }
        }
        if (mounted && created > 0) {
          Get.snackbar('Website updated', '$created plan(s) added to web. WooCommerce now shows ${loadedPlans.length} plan(s).', backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 4));
        }
      }

    } catch (e) {
      print('❌ Error loading workout plans: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _listenToWorkoutPlans() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final currentRole = AppConstants.role;
    if (currentUid == null) return;

    if (currentRole == 'admin') {
      FirebaseFirestore.instance.collection('workout_plans').snapshots().listen((snapshot) {
        if (mounted) setState(() => workoutPlans = snapshot.docs.map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id)).toList());
      });
    }
    else if (currentRole == 'trainer') {
      FirebaseFirestore.instance.collection('workout_plans').where('createdBy', isEqualTo: currentUid).snapshots().listen((snapshot) {
        if (mounted) setState(() => workoutPlans = snapshot.docs.map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id)).toList());
      });
    }
    else {
      FirebaseFirestore.instance.collection('workout_plan_assignments').where('assignedUsers', arrayContains: currentUid).snapshots().listen((assignmentSnapshot) {
        if (assignmentSnapshot.docs.isEmpty) {
          if (mounted) setState(() => workoutPlans = []);
          return;
        }
        final planIds = assignmentSnapshot.docs.map((doc) => doc.id).toList();
        FirebaseFirestore.instance.collection('workout_plans').where(FieldPath.documentId, whereIn: planIds).snapshots().listen((planSnapshot) {
          if (mounted) setState(() => workoutPlans = planSnapshot.docs.map((doc) => WorkoutPlan.fromFirestore(doc.data(), doc.id)).toList());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' || homeController.userRole.value == 'admin';

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Workout Plans', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (homeController.userRole.value == 'admin')
            IconButton(
              icon: Icon(Icons.cleaning_services_rounded, color: textColor),
              tooltip: 'Clean website: remove packages not in Firebase',
              onPressed: () async {
                final plans = workoutPlans;
                if (plans.isEmpty) {
                  Get.snackbar('No plans', 'Load plans first, then clean.', backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                final keepIds = plans.map((p) => p.wooProductId).whereType<String>().where((s) => s.trim().isNotEmpty).toList();
                final deleted = await removePackagesNotInFirestore(keepIds);
                if (mounted) {
                  Get.snackbar(deleted > 0 ? 'Website cleaned' : 'Website in sync', deleted > 0 ? '$deleted old package(s) removed.' : 'Web matches Firebase plans.', backgroundColor: Colors.blue, colorText: Colors.white);
                }
              },
            ),
          if (homeController.userRole.value == 'admin')
            IconButton(
              icon: Icon(Icons.cloud_upload_rounded, color: textColor),
              tooltip: 'Sync all plans to website (so web shows same count as Firebase)',
              onPressed: () async {
                final plans = workoutPlans;
                if (plans.isEmpty) {
                  Get.snackbar('No plans', 'No plans to sync.', backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                int synced = 0;
                int created = 0;
                for (final plan in plans) {
                  final result = await syncPlanToWebsite(
                    title: plan.name,
                    price: plan.price,
                    description: plan.description,
                    imageUrl: (plan.imageUrl != null && plan.imageUrl!.trim().isNotEmpty) ? plan.imageUrl : null,
                    wooProductId: plan.wooProductId,
                    forceCreate: (plan.wooProductId ?? '').trim().isEmpty, // create new product per plan when missing so 3 plans = 3 on web
                  );
                  if (result.success) {
                    synced++;
                    if (result.productId != null && (plan.wooProductId ?? '').trim().isEmpty) {
                      await FirebaseFirestore.instance.collection('workout_plans').doc(plan.id).update({'wooProductId': result.productId});
                      created++;
                    }
                  }
                }
                if (mounted) {
                  Get.snackbar('Sync done', 'Synced $synced plan(s) to web${created > 0 ? ", $created new product(s) created." : "."}', backgroundColor: Colors.green, colorText: Colors.white);
                }
              },
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            tooltip: 'Refresh',
            onPressed: () => _loadWorkoutPlans(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner for Regular Users
          if (!isTrainerOrAdmin)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.green.shade800 : Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are workout plans assigned to you by your trainer',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? _buildWorkoutPlansShimmer(isDark)
                : workoutPlans.isEmpty
                ? _buildEmptyState(isDark)
                : RefreshIndicator(
              onRefresh: _loadWorkoutPlans,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: workoutPlans.length,
                itemBuilder: (context, index) {
                  final plan = workoutPlans[index];
                  return _buildPlanCard(plan, isTrainerOrAdmin, isDark);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isTrainerOrAdmin
          ? FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(isDark),
        backgroundColor: Colors.green.withOpacity(0.8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Plan', style: TextStyle(color: Colors.white)),
      )
          : null,
    );
  }

  Widget _buildWorkoutPlansShimmer(bool isDark) {
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header placeholder (green-ish area)
                Container(
                  height: 88,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 18,
                        width: 160,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body placeholder
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 200, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 140, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(WorkoutPlan plan, bool isTrainerOrAdmin, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => WorkoutPlanDetailScreen(plan: plan, isReadOnly: !isTrainerOrAdmin));
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade900, Colors.green.shade800], // Slightly darker for better contrast
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.fitness_center, size: 14, color: Colors.white.withOpacity(0.8)),
                                const SizedBox(width: 6),
                                Text(
                                  '${plan.exercises.length} exercises',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Exercises List Preview
                if (plan.exercises.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exercises:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 8),
                        ...plan.exercises.take(3).map((ex) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(ex.exerciseName, style: TextStyle(fontSize: 14, color: textColor)),
                              ),
                              Text('${ex.sets}×${ex.reps}', style: TextStyle(fontSize: 12, color: subText)),
                            ],
                          ),
                        )),
                        if (plan.exercises.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${plan.exercises.length - 3} more exercises',
                              style: TextStyle(fontSize: 12, color: subText, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Three-dot menu for trainers/admins
          if (isTrainerOrAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showPlanOptionsSheet(plan, isDark),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Semi-transparent on gradient
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final HomeController homeController = Get.find<HomeController>();
    final bool isStudent = homeController.userRole.value == 'user';
    final Color iconColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 80, color: iconColor),
            const SizedBox(height: 24),
            Text(
              isStudent ? 'No Plans Assigned' : 'No Workout Plans Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              isStudent
                  ? 'Your trainer hasn\'t assigned any workout plans yet'
                  : 'Create your first workout plan to get started',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: subText),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanOptionsSheet(WorkoutPlan plan, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                plan.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.people, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 24),
              ),
              title: Text("Assign to Users", style: TextStyle(fontWeight: FontWeight.w600, color: text)),
              subtitle: Text("Choose which users can see this plan", style: TextStyle(fontSize: 12, color: subText)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () { Navigator.pop(ctx); _showUserAssignmentSheet(plan); },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.visibility, color: isDark ? Colors.green.shade200 : Colors.green.shade700, size: 24),
              ),
              title: Text("View Details", style: TextStyle(fontWeight: FontWeight.w600, color: text)),
              subtitle: Text("See all exercises in this plan", style: TextStyle(fontSize: 12, color: subText)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () { Navigator.pop(ctx); Get.to(() => WorkoutPlanDetailScreen(plan: plan, isReadOnly: false)); },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete, color: isDark ? Colors.red.shade200 : Colors.red.shade700, size: 24),
              ),
              title: Text("Delete Plan", style: TextStyle(fontWeight: FontWeight.w600, color: text)),
              subtitle: Text("Remove this workout plan", style: TextStyle(fontSize: 12, color: subText)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subText),
              onTap: () { Navigator.pop(ctx); _showDeleteConfirmation(plan, isDark); },
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ListTile(
              leading: Icon(Icons.close, color: subText),
              title: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500, color: text)),
              onTap: () => Navigator.pop(ctx),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showUserAssignmentSheet(WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WorkoutPlanUserAssignmentContent(plan: plan),
    );
  }

  void _showDeleteConfirmation(WorkoutPlan plan, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange.shade700),
              const SizedBox(height: 16),
              Text('Delete Plan?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 12),
              Text(
                'This will permanently delete "${plan.name}" and all its exercises.',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final wooId = plan.wooProductId?.trim();
                        await FirebaseFirestore.instance.collection('workout_plans').doc(plan.id).delete();
                        await FirebaseFirestore.instance.collection('workout_plan_assignments').doc(plan.id).delete();
                        if (wooId != null && wooId.isNotEmpty) {
                          await deletePlanFromWebsite(wooId);
                        }
                        Get.snackbar('Deleted', 'Plan deleted successfully', backgroundColor: Colors.red, colorText: Colors.white);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlanDialog(bool isDark) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController(); // 🆕 Price
    final TextEditingController durationController = TextEditingController(); // 🆕 Duration

    // 🆕 Duration Unit Dropdown State
    final RxString selectedUnit = 'Weeks'.obs;
    final List<String> timeUnits = ['Days', 'Weeks', 'Months', 'Years'];

    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[50]!;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView( // Added ScrollView to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.fitness_center, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Create Workout Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text))),
                    IconButton(icon: Icon(Icons.close_rounded, color: text), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. PLAN NAME
                TextField(
                  controller: nameController,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    labelText: 'Plan Name',
                    hintText: 'e.g., Upper Body, Leg Day',
                    labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.edit_rounded, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: inputFill,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // 2. PRICE FIELD (🆕)
                TextField(
                  controller: priceController,
                  style: TextStyle(color: text),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: 'e.g. 25 or 0 for Free',
                    labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                    prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: inputFill,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. DURATION & UNIT ROW (🆕)
                Row(
                  children: [
                    // Duration Number
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: durationController,
                        style: TextStyle(color: text),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          hintText: 'e.g. 4',
                          labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
                          prefixIcon: const Icon(Icons.timer_outlined, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: inputFill,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Unit Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputFill,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit.value,
                            dropdownColor: bg,
                            style: TextStyle(color: text, fontWeight: FontWeight.bold),
                            icon: Icon(Icons.keyboard_arrow_down, color: text),
                            isExpanded: true,
                            items: timeUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if(newValue != null) selectedUnit.value = newValue;
                            },
                          ),
                        )),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // BUTTONS
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final price = priceController.text.trim();
                          final duration = durationController.text.trim();

                          if (name.isEmpty) return;

                          Get.back(); // Close Dialog

                          final currentUid = FirebaseAuth.instance.currentUser?.uid;
                          if (currentUid == null) return;

                          final String imageUrlToUse = "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=250";
                          print('[Plan Create] imageUrlToUse (saving to Firestore): "$imageUrlToUse" (length: ${imageUrlToUse.length})');

                          // ✅ Save to Firestore — always store imageUrl as string so Firebase has it
                          final ref = FirebaseFirestore.instance.collection('workout_plans').doc();
                          await ref.set({
                            'name': name,
                            'price': price.isEmpty ? '0' : price,
                            'duration': duration.isEmpty ? '0' : duration,
                            'durationUnit': selectedUnit.value,
                            'description': '',
                            'exercises': [],
                            'imageUrl': imageUrlToUse,
                            'createdBy': currentUid,
                            'createdAt': FieldValue.serverTimestamp(),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          // Create workout_plan_assignments doc so plan can be assigned to users
                          await FirebaseFirestore.instance.collection('workout_plan_assignments').doc(ref.id).set({
                            'planId': ref.id,
                            'planName': name,
                            'assignedUsers': [],
                          }, SetOptions(merge: true));

                          print('[Plan Create] Firestore saved. Now syncing to website with imageUrl: ${imageUrlToUse.isNotEmpty ? imageUrlToUse : "null"}');
                          WooCommerceSyncResult syncResult;
                          try {
                            syncResult = await syncPlanToWebsite(
                              title: name,
                              price: price.isEmpty ? '0' : price,
                              description: '',
                              imageUrl:  imageUrlToUse ,
                            );
                            print('[Plan Create] Sync completed. success=${syncResult.success} message=${syncResult.message} productId=${syncResult.productId}');
                          } catch (e, st) {
                            print('[Plan Create] Sync THREW: $e\n$st');
                            syncResult = WooCommerceSyncResult.error('$e');
                          }
                          if (syncResult.success && syncResult.productId != null) {
                            await ref.update({'wooProductId': syncResult.productId});
                          }
                          if (syncResult.success) {
                            Get.snackbar('Success', 'Plan "$name" created and synced to website!', backgroundColor: Colors.green, colorText: Colors.white);
                          } else {
                            Get.snackbar('Success', 'Plan "$name" created! (Website sync: ${syncResult.message})', backgroundColor: Colors.orange, colorText: Colors.white);
                          }
                          _loadWorkoutPlans();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Create', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// WORKOUT PLAN DETAIL SCREEN
// Tap exercise card → Opens ChewieDetailScreen with full exercise details
// ==============================================================================
// ==============================================================================
// WORKOUT PLAN DETAIL SCREEN (Themed)
// ==============================================================================

class WorkoutPlanDetailScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final bool isReadOnly;

  const WorkoutPlanDetailScreen({
    super.key,
    required this.plan,
    this.isReadOnly = false,
  });

  @override
  State<WorkoutPlanDetailScreen> createState() => _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  late WorkoutPlan currentPlan;
  final PlanController planController = Get.put(PlanController());
  @override
  void initState() {
    super.initState();
    currentPlan = widget.plan;
    _listenToChanges();

    // ✅ Load Progress when screen opens
    if (!widget.isReadOnly) {
      planController.fetchPlanProgress(widget.plan.id);
    }
  }

  void _listenToChanges() {
    FirebaseFirestore.instance
        .collection('workout_plans')
        .doc(widget.plan.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          currentPlan = WorkoutPlan.fromFirestore(
            snapshot.data() as Map<String, dynamic>,
            snapshot.id,
          );
        });
      }
    });
  }

  /// After a Firestore plan update, sync to WooCommerce. Creates product if no wooProductId.
  /// Returns true if sync succeeded, false if it failed or threw.
  Future<bool> _syncPlanToWebsiteAfterUpdate() async {
    try {
      // Force server read so we get the latest data just saved (avoids stale cache)
      final doc = await FirebaseFirestore.instance
          .collection('workout_plans')
          .doc(currentPlan.id)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) {
        print('[WooCommerce sync] Skip: plan doc missing');
        return false;
      }
      final d = doc.data()!;
      final title = d['name']?.toString() ?? currentPlan.name;
      final price = (d['price'] ?? currentPlan.price).toString();
      final description = d['description']?.toString() ?? currentPlan.description;
      // Support both camelCase and snake_case; fallback to in-memory plan
      String? wooProductId = d['wooProductId']?.toString().trim();
      if (wooProductId == null || wooProductId.isEmpty) {
        wooProductId = d['woo_product_id']?.toString().trim();
      }
      if (wooProductId == null || wooProductId.isEmpty) {
        final fromPlan = currentPlan.wooProductId?.trim();
        if (fromPlan != null && fromPlan.isNotEmpty) wooProductId = fromPlan;
      }
      final imageUrl = d['imageUrl']?.toString();

      final isUpdate = wooProductId != null && wooProductId.isNotEmpty;
      print('[WooCommerce sync] Plan sync: ${isUpdate ? "UPDATE" : "CREATE"} wooProductId=${wooProductId ?? "null"}');

      final result = await syncPlanToWebsite(
        title: title,
        price: price,
        description: description,
        imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl,
        wooProductId: wooProductId,
      );
      if (result.success && result.productId != null && (wooProductId == null || wooProductId.isEmpty)) {
        await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).update({'wooProductId': result.productId});
        print('[WooCommerce sync] Saved wooProductId to Firestore: ${result.productId}');
      }
      if (!result.success) {
        print('[WooCommerce sync] Failed: ${result.message}');
        if (mounted) {
          Get.snackbar(
            'Website sync failed',
            result.message ?? 'Could not sync plan to website',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
        return false;
      }
      return true;
    } catch (e, st) {
      print('[WooCommerce sync] Error during sync: $e');
      print(st);
      if (mounted) {
        Get.snackbar(
          'Website sync error',
          'Plan saved but sync failed: $e',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final bool isTrainerOrAdmin = homeController.userRole.value == 'trainer' ||
        homeController.userRole.value == 'admin';

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(currentPlan.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (isTrainerOrAdmin)
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: textColor),
              tooltip: 'Add Exercise',
              onPressed: () => _showExerciseSelectionSheet(),
            ),
          if (isTrainerOrAdmin)
            IconButton(
              icon: Icon(Icons.edit_rounded, color: textColor),
              tooltip: 'Edit Plan',
              onPressed: () => _showEditPlanDialog(),
            ),
          if (isTrainerOrAdmin)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              tooltip: 'Delete Plan',
              onPressed: () => _showDeleteConfirmation(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade900, Colors.green.shade600], // Darker gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPlan.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentPlan.exercises.length} exercises',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!widget.isReadOnly)
              _buildProgressCalendar(isDark),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Sets', '${_calculateTotalSets()}', Icons.repeat_rounded, Colors.orange, isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Total Reps', '${_calculateTotalReps()}', Icons.fitness_center, Colors.green, isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Est. Time', '${_calculateEstimatedTime()} min', Icons.timer_outlined, Colors.blue, isDark),
                  ),
                ],
              ),
            ),

            // Exercises Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // ALL Exercises List
            if (currentPlan.exercises.isEmpty)
              _buildEmptyExercisesState(isTrainerOrAdmin, isDark)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: currentPlan.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = currentPlan.exercises[index];
                  return _buildExerciseCard(exercise, index, isTrainerOrAdmin, isDark);
                },
              ),
          ],
        ),
      ),
      // ✅ ADD FLOATING BUTTON TO MARK TODAY AS DONE
      floatingActionButton: !widget.isReadOnly ? FloatingActionButton.extended(
        onPressed: () => planController.markTodayComplete(widget.plan.id),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text("Finish Workout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,

    );
  }

  // 📅 NEW WIDGET: Calendar Strip
  Widget _buildProgressCalendar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(left: 16),
      height: 90, // Height of the calendar strip
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Your Schedule",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Start from the day the plan was bought/assigned
              DateTime startDate = planController.planStartDate.value ?? DateTime.now();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 30, // Show next 30 days (or calculate based on duration)
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  // Calculate date for this card
                  DateTime date = startDate.add(Duration(days: index));
                  bool isToday = date.day == DateTime.now().day &&
                      date.month == DateTime.now().month;

                  bool isCompleted = planController.isDateCompleted(date);

                  return Container(
                    width: 55,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green // ✅ Green if Done
                          : (isToday ? Colors.blue.shade800 : (isDark ? const Color(0xFF1E1E1E) : Colors.white)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isToday ? Colors.blueAccent : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                          width: isToday ? 2 : 1
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Day",
                          style: TextStyle(
                              fontSize: 10,
                              color: isCompleted ? Colors.white70 : Colors.grey
                          ),
                        ),
                        Text(
                          "${index + 1}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCompleted || isToday ? Colors.white : (isDark ? Colors.white : Colors.black)
                          ),
                        ),
                        if(isCompleted)
                          const Icon(Icons.check_circle, size: 14, color: Colors.white)
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Show Exercise Selection Bottom Sheet
  void _showExerciseSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseSelectionContent(
        plan: currentPlan,
        onExerciseSelected: (Exercise exercise) async {
          await _addExerciseFromList(exercise);
        },
      ),
    );
  }

  // ✅ NEW: Add Exercise to Plan from List
  Future<void> _addExerciseFromList(Exercise exercise) async {
    try {
      final planDoc = await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).get();
      if (!planDoc.exists) return;

      final planData = planDoc.data()!;
      List<dynamic> exercisesData = planData['exercises'] ?? [];

      bool alreadyExists = exercisesData.any((ex) => ex['exerciseId'] == exercise.id.toString());

      if (alreadyExists) {
        Get.snackbar('Already Added', '${exercise.name} is already in ${currentPlan.name}', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final now = DateTime.now().toIso8601String();
      exercisesData.add({
        'exerciseId': exercise.id.toString(),
        'exerciseName': exercise.name,
        'category': exercise.category,
        'difficulty': exercise.difficulty,
        'sets': 3,
        'reps': 12,
        'rest': 60,
        'addedAt': now,
      });

      await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).update({
        'exercises': exercisesData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _syncPlanToWebsiteAfterUpdate();
      Get.snackbar('Added', '${exercise.name} added to ${currentPlan.name}', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add exercise', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index, bool canEdit, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _openExerciseDetail(exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.exerciseName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        if (exercise.category.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              exercise.category,
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (canEdit)
                    PopupMenuButton<String>(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      icon: Icon(Icons.more_vert, color: subText),
                      onSelected: (value) {
                        if (value == 'edit') _showEditExerciseDialog(exercise, index);
                        else if (value == 'delete') _deleteExercise(index);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20, color: Colors.blue), SizedBox(width: 12), Text('Edit', style: TextStyle(color: textColor))])),
                        PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(color: textColor))])),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildExerciseDetail('Sets', '${exercise.sets}', Icons.repeat_rounded, Colors.orange, subText)),
                  Expanded(child: _buildExerciseDetail('Reps', '${exercise.reps}', Icons.fitness_center, Colors.green, subText)),
                  Expanded(child: _buildExerciseDetail('Rest', '${exercise.rest}s', Icons.timer_outlined, Colors.blue, subText)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseDetail(String label, String value, IconData icon, Color color, Color labelColor) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
      ],
    );
  }

  Widget _buildEmptyExercisesState(bool canAdd, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.fitness_center_outlined, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No Exercises Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(
              canAdd ? 'Tap the + icon in the toolbar to add exercises' : 'Your trainer will add exercises soon',
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openExerciseDetail(WorkoutExercise exercise) {
    // Navigate to detail screen
    final exerciseDetail = Exercise(
      id: int.tryParse(exercise.exerciseId) ?? 0,
      name: exercise.exerciseName,
      category: exercise.category,
      difficulty: exercise.difficulty,
      steps: [],
      targetMuscles: [],
      grips: [],
    );
    final MuscleWikiController muscleController = Get.find<MuscleWikiController>();
    Get.to(() => ChewieDetailScreen(
        exercise: exerciseDetail,
       // apiKey: muscleController.apiKey,
        genderPreference: muscleController.selectedGender.value));
  }

  int _calculateTotalSets() => currentPlan.exercises.fold(0, (sum, ex) => sum + ex.sets);
  int _calculateTotalReps() => currentPlan.exercises.fold(0, (sum, ex) => sum + (ex.sets * ex.reps));
  int _calculateEstimatedTime() => currentPlan.exercises.fold(0, (time, ex) => time + (ex.sets * 2) + ((ex.sets - 1) * (ex.rest ~/ 60)));

  void _showEditPlanDialog() {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[50]!;

    final nameController = TextEditingController(text: currentPlan.name);
    final descController = TextEditingController(text: currentPlan.description);
    final priceController = TextEditingController(text: currentPlan.price);
    final durationController = TextEditingController(text: currentPlan.duration);

    final List<String> timeUnits = ['Days', 'Weeks', 'Months', 'Years'];
    final String initialUnit = timeUnits.contains(currentPlan.durationUnit) ? currentPlan.durationUnit : 'Weeks';
    final RxString selectedUnit = initialUnit.obs;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Workout Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
                const SizedBox(height: 24),
                // 1. Plan Name (same as Create)
                TextField(
                  controller: nameController,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    labelText: 'Plan Name',
                    hintText: 'e.g., Upper Body, Leg Day',
                    labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.red),
                    prefixIcon: const Icon(Icons.edit_rounded, color: Colors.grey),
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // 2. Price (same as Create)
                TextField(
                  controller: priceController,
                  style: TextStyle(color: text),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: 'e.g. 25 or 0 for free',
                    labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.red),
                    prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.grey),
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // 3. Duration + Unit (same as Create)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: durationController,
                        style: TextStyle(color: text),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          hintText: 'e.g. 4',
                          labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.red),
                          prefixIcon: const Icon(Icons.timer_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputFill,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit.value,
                            dropdownColor: bg,
                            style: TextStyle(color: text, fontWeight: FontWeight.bold),
                            icon: Icon(Icons.keyboard_arrow_down, color: text),
                            isExpanded: true,
                            items: timeUnits.map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? v) {
                              if (v != null) selectedUnit.value = v;
                            },
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 4. Description (same as Create)
                TextField(
                  controller: descController,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.red),
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          final price = priceController.text.trim();
                          final duration = durationController.text.trim();
                          try {
                            await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).update({
                              'name': name,
                              'description': descController.text.trim(),
                              'price': price.isEmpty ? '0' : price,
                              'duration': duration.isEmpty ? '0' : duration,
                              'durationUnit': selectedUnit.value,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                            Get.back();
                            final synced = await _syncPlanToWebsiteAfterUpdate();
                            Get.snackbar(
                              'Updated',
                              synced ? 'Plan updated and synced to website' : 'Plan saved (website sync failed — see message above)',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to save plan: $e', backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditExerciseDialog(WorkoutExercise exercise, int index) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color inputFill = isDark ? const Color(0xFF2C2C2E) : Colors.grey[50]!;

    final setsController = TextEditingController(text: '${exercise.sets}');
    final repsController = TextEditingController(text: '${exercise.reps}');
    final restController = TextEditingController(text: '${exercise.rest}');

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit ${exercise.exerciseName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _buildNumberInput(setsController, 'Sets', inputFill, text, isDark),
              const SizedBox(height: 16),
              _buildNumberInput(repsController, 'Reps', inputFill, text, isDark),
              const SizedBox(height: 16),
              _buildNumberInput(restController, 'Rest (s)', inputFill, text, isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final sets = int.tryParse(setsController.text) ?? 3;
                        final reps = int.tryParse(repsController.text) ?? 12;
                        final rest = int.tryParse(restController.text) ?? 60;
                        Get.back();
                        await _updateExercise(index, sets, reps, rest);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(TextEditingController controller, String label, Color fill, Color text, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(color: text),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.blue),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _updateExercise(int index, int sets, int reps, int rest) async {
    final updatedExercises = List<Map<String, dynamic>>.from(currentPlan.exercises.map((ex) => ex.toMap()));
    updatedExercises[index]['sets'] = sets;
    updatedExercises[index]['reps'] = reps;
    updatedExercises[index]['rest'] = rest;

    await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).update({
      'exercises': updatedExercises,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _syncPlanToWebsiteAfterUpdate();
    Get.snackbar('Updated', 'Exercise updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _showDeleteConfirmation() {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Delete Plan?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 12),
              Text('This will permanently delete this plan.', style: TextStyle(color: isDark ? Colors.grey : Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: text)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        Get.back(); // Close screen
                        final wooId = currentPlan.wooProductId?.trim();
                        await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).delete();
                        await FirebaseFirestore.instance.collection('workout_plan_assignments').doc(currentPlan.id).delete();
                        if (wooId != null && wooId.isNotEmpty) {
                          await deletePlanFromWebsite(wooId);
                        }
                        Get.snackbar('Deleted', 'Plan deleted', backgroundColor: Colors.red, colorText: Colors.white);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteExercise(int index) async {
    final updatedExercises = List<Map<String, dynamic>>.from(currentPlan.exercises.map((ex) => ex.toMap()));
    updatedExercises.removeAt(index);
    await FirebaseFirestore.instance.collection('workout_plans').doc(currentPlan.id).update({
      'exercises': updatedExercises,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _syncPlanToWebsiteAfterUpdate();
    Get.snackbar('Removed', 'Exercise removed', backgroundColor: Colors.red, colorText: Colors.white);
  }
}

// Extension to help with mapping
extension on WorkoutExercise {
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'rest': rest,
    };
  }
}

// ✅ NEW: Exercise Selection Bottom Sheet Widget with Multiple Selection
class _ExerciseSelectionContent extends StatefulWidget {
  final WorkoutPlan plan;
  final Function(Exercise) onExerciseSelected;

  const _ExerciseSelectionContent({
    required this.plan,
    required this.onExerciseSelected,
  });

  @override
  State<_ExerciseSelectionContent> createState() => _ExerciseSelectionContentState();
}

class _ExerciseSelectionContentState extends State<_ExerciseSelectionContent> {
  final MuscleWikiController muscleController = Get.find<MuscleWikiController>();
  final TextEditingController searchController = TextEditingController();
  List<Exercise> filteredExercises = [];
  bool isSearching = false;

  // ✅ NEW: Track selected exercises and already added exercises
  Set<String> selectedExerciseIds = {};
  Set<String> alreadyAddedExerciseIds = {};
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    filteredExercises = muscleController.exercises.toList();

    // ✅ Get list of already added exercise IDs
    alreadyAddedExerciseIds = widget.plan.exercises
        .map((ex) => ex.exerciseId)
        .toSet();

    print('📋 Already added exercises: $alreadyAddedExerciseIds');
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredExercises = muscleController.exercises.toList();
        isSearching = false;
      } else {
        isSearching = true;
        filteredExercises = muscleController.exercises.where((ex) {
          return ex.name.toLowerCase().contains(query.toLowerCase()) ||
              ex.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // ✅ NEW: Toggle exercise selection
  void _toggleExercise(String exerciseId) {
    setState(() {
      if (selectedExerciseIds.contains(exerciseId)) {
        selectedExerciseIds.remove(exerciseId);
      } else {
        selectedExerciseIds.add(exerciseId);
      }
    });
  }

  // ✅ NEW: Save all selected exercises
  Future<void> _saveSelectedExercises() async {
    if (selectedExerciseIds.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select at least one exercise',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final planDoc = await FirebaseFirestore.instance
          .collection('workout_plans')
          .doc(widget.plan.id)
          .get();

      if (!planDoc.exists) {
        throw Exception('Plan not found');
      }

      final planData = planDoc.data()!;
      List<dynamic> exercisesData = List.from(planData['exercises'] ?? []);

      int addedCount = 0;
      final now = DateTime.now().toIso8601String();

      // Add each selected exercise
      for (String exerciseId in selectedExerciseIds) {
        // Find the exercise object
        final exercise = filteredExercises.firstWhere(
              (ex) => ex.id.toString() == exerciseId,
          orElse: () => muscleController.exercises.firstWhere(
                (ex) => ex.id.toString() == exerciseId,
          ),
        );

        // Add to plan
        exercisesData.add({
          'exerciseId': exercise.id.toString(),
          'exerciseName': exercise.name,
          'category': exercise.category,
          'difficulty': exercise.difficulty,
          'sets': 3,
          'reps': 12,
          'rest': 60,
          'addedAt': now,
        });

        addedCount++;
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('workout_plans')
          .doc(widget.plan.id)
          .update({
        'exercises': exercisesData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        Get.snackbar(
          'Success',
          '$addedCount exercise${addedCount > 1 ? 's' : ''} added to ${widget.plan.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Error saving exercises: $e');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save exercises: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Exercises",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add to ${widget.plan.name}",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // ✅ Selection counter
                if (selectedExerciseIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedExerciseIds.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterExercises('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: _filterExercises,
            ),
          ),

          const Divider(height: 24),

          // Exercise List
          Flexible(
            child: filteredExercises.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "No exercises found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try a different search term",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: filteredExercises.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                final exerciseId = exercise.id.toString();
                final isSelected = selectedExerciseIds.contains(exerciseId);
                final isAlreadyAdded = alreadyAddedExerciseIds.contains(exerciseId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isSelected ? 3 : 1,
                  color: isAlreadyAdded
                      ? Colors.green.shade50
                      : (isSelected ? Colors.blue.shade50 : Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isAlreadyAdded
                          ? Colors.green
                          : (isSelected ? Colors.blue : Colors.grey.shade200),
                      width: isSelected || isAlreadyAdded ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    // ✅ Checkbox on the left
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isSelected || isAlreadyAdded,
                          onChanged: isAlreadyAdded
                              ? null
                              : (bool? value) {
                            _toggleExercise(exerciseId);
                          },
                          activeColor: isAlreadyAdded ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(exercise.getCategoryImage()),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isAlreadyAdded ? Colors.green.shade800 : Colors.black,
                            ),
                          ),
                        ),
                        // ✅ "Already Added" badge
                        if (isAlreadyAdded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Added',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (exercise.category.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exercise.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (exercise.difficulty.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exercise.difficulty,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: isAlreadyAdded
                        ? null
                        : () => _toggleExercise(exerciseId),
                  ),
                );
              },
            ),
          ),

          // ✅ Save Button at Bottom
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Info text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedExerciseIds.isEmpty
                            ? 'Select exercises to add'
                            : '${selectedExerciseIds.length} exercise${selectedExerciseIds.length > 1 ? 's' : ''} selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedExerciseIds.isEmpty
                              ? Colors.grey.shade600
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Save button
                ElevatedButton.icon(
                  onPressed: isSaving || selectedExerciseIds.isEmpty
                      ? null
                      : _saveSelectedExercises,
                  icon: isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedExerciseIds.isEmpty
                        ? Colors.grey
                        : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: selectedExerciseIds.isEmpty ? 0 : 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// USER ASSIGNMENT WIDGET FOR WORKOUT PLANS
// ==========================================

// ==========================================
// USER ASSIGNMENT WIDGET FOR WORKOUT PLANS (THEMED)
// ==========================================

class _WorkoutPlanUserAssignmentContent extends StatefulWidget {
  final WorkoutPlan plan;

  const _WorkoutPlanUserAssignmentContent({required this.plan});

  @override
  State<_WorkoutPlanUserAssignmentContent> createState() =>
      _WorkoutPlanUserAssignmentContentState();
}

class _WorkoutPlanUserAssignmentContentState
    extends State<_WorkoutPlanUserAssignmentContent> {
  Map<String, bool> selectedUsers = {};
  List<Map<String, dynamic>> myStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentsAndAssignments();
  }

  Future<void> _loadStudentsAndAssignments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      // Load all users with role='user'
      var studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      myStudents = studentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
        };
      }).toList();

      // Load current assignments for this plan
      final assignmentDoc = await FirebaseFirestore.instance
          .collection('workout_plan_assignments')
          .doc(widget.plan.id)
          .get();

      if (assignmentDoc.exists) {
        final data = assignmentDoc.data();
        List assignedUsers = data?['assignedUsers'] ?? [];

        for (var student in myStudents) {
          String studentUid = student['uid'];
          selectedUsers[studentUid] = assignedUsers.contains(studentUid);
        }
      } else {
        for (var student in myStudents) {
          selectedUsers[student['uid']] = false;
        }
      }
    } catch (e) {
      print('❌ Error loading students: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveAssignments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      // Get list of assigned user IDs
      List<String> assignedUserIds = selectedUsers.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('workout_plan_assignments')
          .doc(widget.plan.id)
          .set({
        'planId': widget.plan.id,
        'planName': widget.plan.name,
        'assignedUsers': assignedUserIds,
        'assignedBy': currentUid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Auto-grant visibility for all exercises in the plan
      if (widget.plan.exercises.isNotEmpty && assignedUserIds.isNotEmpty) {
        for (var exercise in widget.plan.exercises) {
          String exerciseId = exercise.exerciseId;
          String exerciseName = exercise.exerciseName;

          final visDocRef = FirebaseFirestore.instance
              .collection('exercise_visibility')
              .doc(exerciseId);

          final visDoc = await visDocRef.get();

          if (visDoc.exists) {
            var data = visDoc.data()!;
            List<dynamic> currentVisibleUsers = data['visibleForUsers'] ?? [];
            Set<String> updatedVisibleUsers = Set<String>.from(currentVisibleUsers);
            updatedVisibleUsers.addAll(assignedUserIds);

            await visDocRef.update({
              'visibleForUsers': updatedVisibleUsers.toList(),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          } else {
            await visDocRef.set({
              'exerciseId': exerciseId,
              'exerciseName': exerciseName,
              'isVisibleToAll': false,
              'visibleForUsers': assignedUserIds,
              'controlledBy': currentUid,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      if (mounted) {
        Get.snackbar(
          'Saved',
          'Plan assigned to ${assignedUserIds.length} user(s)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save assignments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color iconBg = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50;
    final Color iconColor = isDark ? Colors.blue.shade200 : Colors.blue;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.people, color: iconColor, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assign Plan to Users",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.plan.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: subText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: text),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),

          // User List
          Flexible(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : myStudents.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: isDark ? Colors.grey.shade700 : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Students Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add students to assign plans",
                      style: TextStyle(
                        color: subText,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: myStudents.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                var student = myStudents[index];
                String studentUid = student['uid'];
                String studentName = student['name'];
                String studentEmail = student['email'];
                bool isAssigned = selectedUsers[studentUid] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: dividerColor),
                  ),
                  child: CheckboxListTile(
                    value: isAssigned,
                    onChanged: (val) {
                      setState(() {
                        selectedUsers[studentUid] = val ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    title: Text(
                      studentName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: text,
                      ),
                    ),
                    subtitle: studentEmail.isNotEmpty
                        ? Text(
                      studentEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: subText,
                      ),
                    )
                        : null,
                    secondary: CircleAvatar(
                      backgroundColor: isAssigned
                          ? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50)
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                      child: Icon(
                        isAssigned
                            ? Icons.fitness_center
                            : Icons.person_outline,
                        color: isAssigned ? (isDark ? Colors.blue.shade200 : Colors.blue) : Colors.grey,
                        size: 20,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),

          // Info Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Selected users will see this plan in their workout section",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _saveAssignments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 4. DETAIL SCREEN (Themed)
// ==========================================
class ChewieDetailScreen extends StatefulWidget {
  final Exercise exercise;
 //final String apiKey;
  final String genderPreference;

  const ChewieDetailScreen({
    super.key,
    required this.exercise,
    //required this.apiKey,
    required this.genderPreference,
  });

  @override
  State<ChewieDetailScreen> createState() => _ChewieDetailScreenState();
}

class _ChewieDetailScreenState extends State<ChewieDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isPageLoading = true;
  bool _loadedFromCache = false;
  String? _fetchedImageUrl;
  List<String> _fetchedSteps = [];

  List<String> _targetMuscles = [];
  List<String> _grips = [];
  String? _difficulty;
  String? _force;
  String? _mechanic;

  // 🎨 Brand Color
  final Color _brandBlue = const Color(0xFF1565C0);

  final String baseUrl = "https://stripe-backend-sigma.vercel.app/api/musclewiki";

  Map<String, String> _defaultHeaders() {
    return const {
      'Accept': 'application/json',
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchedSteps = widget.exercise.steps;
    _loadCachedDataFirst();
  }

  // ... (Keep your existing methods: _loadCachedDataFirst, _applyDetailData, fetchFullDetails, initializePlayer)

  // 🆕 LOAD FROM CACHE FIRST
  Future<void> _loadCachedDataFirst() async {
    Map<String, dynamic>? cachedDetail = await AppConstants.getCachedExerciseDetail(widget.exercise.id);
    if (cachedDetail != null) {
      setState(() {
        _loadedFromCache = true;
        _applyDetailData(cachedDetail);
        _isPageLoading = false;
      });
      fetchFullDetails(silentUpdate: true);
    } else {
      fetchFullDetails(silentUpdate: false);
    }
  }

  void _applyDetailData(Map<String, dynamic> json) {
    String videoUrl = "";
    String imageUrl = "";
    if (json['videos'] != null && (json['videos'] as List).isNotEmpty) {
      videoUrl = json['videos'][0]['url'] ?? "";
      imageUrl = json['videos'][0]['og_image'] ?? "";
    } else if (json['video'] is String) {
      videoUrl = json['video'];
    }

    List<String> safeParse(dynamic field) {
      if (field == null) return [];
      if (field is List) return List<String>.from(field.map((e) => e.toString()));
      if (field is String) return [field];
      return [];
    }

    if (json['steps'] != null) {
      _fetchedSteps = List<String>.from(json['steps']);
    }
    _fetchedImageUrl = imageUrl;
    _targetMuscles = safeParse(json['primary_muscles'] ?? json['muscle']);
    _grips = safeParse(json['grips']);
    _difficulty = json['difficulty'];
    _force = json['force'];
    _mechanic = json['mechanic'];

    if (videoUrl.isNotEmpty) {
      initializePlayer(videoUrl);
    }
  }

  Future<void> fetchFullDetails({bool silentUpdate = false}) async {
    try {
      final uri = Uri.parse(baseUrl);

      // Vercel માટે endpoint અને query parameters સેટ કર્યા
      Map<String, String> queryParams = {
        'endpoint': 'exercises/${widget.exercise.id}',
      };

      if (widget.genderPreference != "Both") {
        queryParams['gender'] = widget.genderPreference.toLowerCase();
      }

      final urlWithParams = uri.replace(queryParameters: queryParams);
      final response = await http.get(urlWithParams, headers: _defaultHeaders());



      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        await AppConstants.cacheExerciseDetail(widget.exercise.id, json);
        if (mounted) {
          setState(() {
            _applyDetailData(json);
            if (!silentUpdate) _isPageLoading = false;
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print("❌ AUTH ERROR (${response.statusCode}) on details: ${response.body}");
        if (!_loadedFromCache && mounted) setState(() => _isPageLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized while loading exercise details.')),
          );
        }
      } else {
        if (!_loadedFromCache && mounted) setState(() => _isPageLoading = false);
      }
    } catch (e) {
      if (!_loadedFromCache && mounted) setState(() => _isPageLoading = false);
    }
  }

  Future<void> initializePlayer(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );
      if (mounted) setState(() {});
    } catch (e) {
      print("Video player error: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white70 : Colors.grey;
    final Color indicatorColor = isDark ? Colors.blue.shade200 : _brandBlue;

    return Scaffold(
      backgroundColor: bg, // ✅ Dynamic BG
      appBar: AppBar(
        title: Text(
          widget.exercise.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: text),
        ),
        backgroundColor: bg, // ✅ Dynamic AppBar
        foregroundColor: text,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: indicatorColor,
          unselectedLabelColor: iconColor,
          indicatorColor: indicatorColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "GUIDE", icon: Icon(Icons.menu_book_rounded)),
            Tab(text: "VIDEO", icon: Icon(Icons.play_circle_filled_rounded)),
          ],
        ),
      ),
      body: _isPageLoading
          ? _buildFullScreenShimmer(isDark)
          : TabBarView(
        controller: _tabController,
        children: [
          _buildGuideTab(isDark, text),
          _buildVideoTab(),
        ],
      ),
    );
  }

  Widget _buildGuideTab(bool isDark, Color textColor) {
    // 🎨 Dynamic Colors for Tab Content
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.black87;
    final Color shadowColor = isDark ? Colors.black26 : Colors.grey.withOpacity(0.2);
    final Color placeholderBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_fetchedImageUrl != null && _fetchedImageUrl!.isNotEmpty)
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _fetchedImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: placeholderBg,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
          Text("Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              ..._targetMuscles.map((m) => _buildDetailChip(m, Colors.blue, isDark)),
              if (_difficulty != null)
                _buildDetailChip("LEVEL: $_difficulty", Colors.purple, isDark),
              if (_force != null) _buildDetailChip("FORCE: $_force", Colors.teal, isDark),
              if (_mechanic != null)
                _buildDetailChip("MECHANIC: $_mechanic", Colors.indigo, isDark),
              ..._grips.map((g) => _buildDetailChip("GRIP: $g", Colors.brown, isDark)),
            ],
          ),
          const SizedBox(height: 30),
          Text("Instructions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 15),
          if (_fetchedSteps.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: placeholderBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "No instructions available",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._fetchedSteps.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg, // ✅ Dynamic Card
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border(
                    left: BorderSide(color: _brandBlue, width: 5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _brandBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$idx",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: subText, // ✅ Dynamic Text
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, Color color, bool isDark) {
    // 🎨 Chip Colors
    final Color chipBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = color.withOpacity(isDark ? 0.4 : 0.5);
    final Color textColor = isDark ? color.withOpacity(0.9) : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipBg, // ✅ Dynamic Chip BG
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFullScreenShimmer(bool isDark) {
    // 🎨 Shimmer Colors
    final Color baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final Color containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 25),
            Container(height: 20, width: 150, color: containerColor),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              children: [
                Container(height: 30, width: 80, color: containerColor),
                Container(height: 30, width: 100, color: containerColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTab() {
    return Container(
      color: Colors.black, // Video always looks best on black
      child: Center(
        child: _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}