import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_controller.dart';
import '../../model/exercise_model.dart';
import 'package:chewie/chewie.dart'; // ✅ Chewie Import કર્યું
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(ExerciseController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Add New Exercise")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: "Exercise Name (e.g. Push Up)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.muscleController,
              decoration: const InputDecoration(labelText: "Muscle Group (e.g. Chest)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.videoUrlController,
              decoration: const InputDecoration(labelText: "Video URL (YouTube/Vimeo)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.instructionsController,
              decoration: const InputDecoration(labelText: "Instructions / Tips"),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: controller.isLoading.value ? null : controller.addExercise,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE EXERCISE", style: TextStyle(color: Colors.white)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}



class AllExercisesScreen extends StatelessWidget {
  const AllExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseController controller = Get.put(ExerciseController());
    bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("All Exercises"),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (controller.exerciseList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.exerciseList.isEmpty) {
          return const Center(child: Text("No exercises found. Add some!"));
        }

        // ✅ GRID VIEW IMPLEMENTATION
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // એક લાઈનમાં 2 બોક્સ
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // કાર્ડની સાઈઝ એડજસ્ટ કરવા
          ),
          itemCount: controller.exerciseList.length,
          itemBuilder: (context, index) {
            final exercise = controller.exerciseList[index];

            return GestureDetector(
              onTap: () {
                // ✅ Open Detail Screen on Tap
                Get.to(() => ExerciseDetailScreenYoutube(exercise: exercise));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Image / Icon Placeholder ---
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Center(
                          child: Text(
                            exercise.name.isNotEmpty ? exercise.name[0].toUpperCase() : "?",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white30 : Colors.blue.shade200
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- Details ---
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.muscleGroup,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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



class ExerciseDetailScreenYoutube extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreenYoutube({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreenYoutube> createState() => _ExerciseDetailScreenYoutubeState();
}

class _ExerciseDetailScreenYoutubeState extends State<ExerciseDetailScreenYoutube> {
  // Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  bool _isYouTube = false;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    String url = widget.exercise.videoUrl;

    if (url.isEmpty) return;

    // ૧. પહેલા ચેક કરો: શું આ YouTube લિંક છે?
    String? videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId != null) {
      // ✅ હા, આ YouTube છે -> YoutubePlayer વાપરો
      _isYouTube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
          forceHD: false,
        ),
      );
      setState(() {
        _isVideoInitialized = true;
      });
    } else {
      // ❌ ના, આ સાદો વિડીયો છે -> Chewie વાપરો
      _isYouTube = false;
      _initializeChewie(url);
    }
  }

  Future<void> _initializeChewie(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return const Center(child: Text("Error loading video", style: TextStyle(color: Colors.white)));
        },
      );

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print("Video Error: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bg = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: bg,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SMART PLAYER BOX ---
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: _isVideoInitialized
                  ? (_isYouTube
              // જો YouTube હોય તો આ
                  ? YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
              )
              // જો સાદો વિડીયો હોય તો આ
                  : (_chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator(color: Colors.red))))
                  : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text("Loading Video...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // --- DETAILS ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(
                      widget.exercise.muscleGroup.toUpperCase(),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Instructions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.exercise.instructions.isNotEmpty
                        ? widget.exercise.instructions
                        : "No instructions provided.",
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}