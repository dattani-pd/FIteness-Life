import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/controller.dart';
import '../../controllers/exercise_visibility_controller.dart';
import '../screen.dart';
import 'exercise_video_player.dart';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';



import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- CONTROLLERS ---
import '../../controllers/wger_controller.dart';

// --- SCREENS ---
import 'wger_detail_screen.dart';




// ==============================================================================
// WGER WORKOUT SCREEN - CORRECTED VERSION
// ==============================================================================

// ⚠️ KEY CHANGES:
// 1. Changed isExerciseHiddenStream() → isExerciseVisibleStream()
// 2. Reversed logic: method now returns TRUE if visible, FALSE if hidden
// 3. Updated checkbox logic to match new behavior

class WgerWorkoutScreen extends StatelessWidget {
  static const pageId = "/WgerWorkoutScreen";
  const WgerWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WgerController controller = Get.put(WgerController());
    final HomeController homeController = Get.find<HomeController>();
    final ExerciseVisibilityController visController = Get.put(ExerciseVisibilityController());
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("WorkOuts"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context, controller),
              ),
              if (controller.selectedCategoryId.value != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Category Chips
          Obx(() {
            if (controller.categoryList.isEmpty) return const SizedBox.shrink();
            return Container(
              height: 50,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.transparent, Colors.transparent, Colors.white],
                    stops: [0.0, 0.05, 0.95, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstOut,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Obx(() => _buildCategoryChip(
                        "All",
                        controller.selectedCategoryId.value == null,
                            () => controller.filterByCategory(null),
                      )),
                    ),
                    ...controller.categoryList.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() => _buildCategoryChip(
                          cat['name'],
                          controller.selectedCategoryId.value == cat['id'],
                              () => controller.filterByCategory(cat['id']),
                        )),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }),

          // Exercise Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        "Loading exercises...",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              final exercises = controller.filteredExercises;

              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "No exercises found",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Try changing your filter",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.loadWgerData;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    final hasImage = (ex['imageUrls'] as List).isNotEmpty;
                    final hasVideo = (ex['videoUrls'] as List).isNotEmpty;
                    final imgUrl = hasImage ? (ex['imageUrls'] as List)[0] : null;

                    bool isHidden = controller.isHidden(ex['id']);
                    bool isTrainer = homeController.userRole.value != 'user';

                    return Card(
                      margin: EdgeInsets.zero,
                      color: (isTrainer && isHidden) ? Colors.red.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: Stack(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Get.to(() => WgerDetailScreen(exercise: ex)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: hasImage
                                              ? CachedNetworkImage(
                                            imageUrl: imgUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(color: Colors.grey[300]),
                                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                          )
                                              : (hasVideo
                                              ? const Center(child: Icon(Icons.play_circle_fill, size: 45))
                                              : const Center(child: Icon(Icons.fitness_center, size: 40, color: Colors.grey))),
                                        ),
                                        if (controller.selectedCategoryId.value == null)
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                ex['category'] ?? 'General',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex['name'],
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                decoration: (isTrainer && isHidden) ? TextDecoration.lineThrough : null
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          if (ex['description'] != null &&
                                              ex['description'].isNotEmpty &&
                                              ex['description'] != "No description available.")
                                            Expanded(
                                              child: Text(
                                                ex['description'],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          else
                                            const SizedBox(height: 4),
                                          if (ex['muscles'] != null && (ex['muscles'] as List).isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.accessibility_new, size: 12, color: Colors.blue[700]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${(ex['muscles'] as List).length} muscle${(ex['muscles'] as List).length > 1 ? 's' : ''}",
                                                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (isTrainer && isHidden)
                                            const Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                "HIDDEN FROM ALL",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isTrainer)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.black, shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 4)
                                ]),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onSelected: (value) {
                                  if (value == 'hide_all') {
                                    controller.toggleExerciseVisibility(ex['id']);
                                  }
                                  else if (value == 'hide_select') {
                                    _showStudentVisibilitySheet(context, visController, ex);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'hide_all',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isHidden ? Icons.visibility : Icons.visibility_off,
                                          color: isHidden ? Colors.green : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(isHidden ? "Show to All" : "Hide from All"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'hide_select',
                                    child: Row(
                                      children: [
                                        Icon(Icons.people, color: Colors.blue, size: 20),
                                        SizedBox(width: 10),
                                        Text("Select Students to Show"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
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

  // ==============================================================================
  // ✅ CORRECTED STUDENT VISIBILITY SHEET
  // ==============================================================================
  void _showStudentVisibilitySheet(
      BuildContext context,
      ExerciseVisibilityController visController,
      Map<String, dynamic> exercise
      ) {
    String exerciseId = exercise['id'].toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
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
                        color: Colors.green.shade50, // Changed from red
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.visibility, color: Colors.green), // Changed icon
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Show to Students", // Updated text
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise['name'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (visController.myStudents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 15),
                          Text("No students found.", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visController.myStudents.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      var student = visController.myStudents[index];
                      String name = student['name'];
                      String email = student['email'];
                      String studentUid = student['uid'];
                      String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

                      // ✅ FIXED: Use isExerciseVisibleStream and reverse logic
                      return StreamBuilder<bool>(
                        stream: visController.isExerciseVisibleStream(exerciseId, studentUid),
                        initialData: true, // Default is visible
                        builder: (context, snapshot) {
                          bool isVisible = snapshot.data ?? true;

                          // ✅ Updated styling (green = visible, red = hidden)
                          Color bgColor = isVisible ? Colors.green.shade50 : Colors.white;
                          Color borderColor = isVisible ? Colors.green.shade200 : Colors.grey.shade200;
                          Color textColor = isVisible ? Colors.green.shade800 : Colors.black87;

                          return Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: borderColor),
                            ),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              activeColor: Colors.green, // Green when checked
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              secondary: CircleAvatar(
                                radius: 22,
                                backgroundColor: isVisible ? Colors.green.shade100 : Colors.grey.shade100,
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isVisible ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(email, style: const TextStyle(fontSize: 12)),

                              // ✅ FIXED: Checkbox value represents visibility (checked = can see)
                              value: isVisible,
                              onChanged: (val) {
                                visController.toggleExerciseForUser(
                                    exerciseId,
                                    exercise['name'],
                                    studentUid
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),

              // ✅ Updated info banner
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WgerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter by Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFilterChip(
                          "All",
                          controller.selectedCategoryId.value == null,
                              () {
                            controller.filterByCategory(null);
                            Navigator.pop(context);
                          },
                        ),
                        ...controller.categoryList.map((cat) {
                          return _buildFilterChip(
                            cat['name'],
                            controller.selectedCategoryId.value == cat['id'],
                                () {
                              controller.filterByCategory(cat['id']);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}