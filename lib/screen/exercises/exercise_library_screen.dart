import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_controller.dart';
import '../../model/model.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller to get data
    final ExerciseController controller = Get.put(ExerciseController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Exercise Library", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.exerciseList.isEmpty) {
          return const Center(child: Text("No exercises found yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.exerciseList.length,
          itemBuilder: (context, index) {
            ExerciseModel exercise = controller.exerciseList[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. VIDEO THUMBNAIL (Placeholder for now)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Icon(Icons.play_circle_fill, size: 50, color: Colors.red.withOpacity(0.7)),
                    ),
                  ),

                  // 2. TEXT INFO
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            exercise.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            exercise.muscleGroup.toUpperCase(),
                            style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          exercise.instructions,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}