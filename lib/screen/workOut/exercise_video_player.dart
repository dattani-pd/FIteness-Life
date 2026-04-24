import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

//import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ExerciseVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;
  bool _isInitialized = false;
  bool _hasStartedPlaying = false; // Track if user has started playing
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print("🎬 Initializing video: ${widget.videoUrl}");
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
        ),
        errorBuilder: (context, errorMessage) {
          print("❌ Chewie error: $errorMessage");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  "Error loading video",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          );
        },
      );

      print("✅ Video initialized successfully");
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("❌ Video initialization error: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _playVideo() {
    if (_videoPlayerController.value.isInitialized) {
      setState(() {
        _hasStartedPlaying = true;
      });
      _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Error state
    if (_isError) {
      return Container(
        height: 250,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.grey, size: 50),
              const SizedBox(height: 10),
              Text(
                "Video could not be loaded",
                style: TextStyle(color: Colors.grey[400]),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (!_isInitialized || _chewieController == null) {
      return Container(
        height: 250,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Show thumbnail overlay before first play
    if (!_hasStartedPlaying) {
      return SizedBox(
        height: 250,
        child: Stack(
          children: [
            // Video thumbnail (first frame)
            SizedBox(
              width: double.infinity,
              height: 250,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController.value.size.width,
                  height: _videoPlayerController.value.size.height,
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
            ),

            // Play button overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: _playVideo,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 50,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            "Tap to play",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show video player after user taps play
    return SizedBox(
      height: 250,
      child: Chewie(controller: _chewieController!),
    );
  }
}



////Youtube Package
// class ExerciseVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//
//   const ExerciseVideoPlayer({super.key, required this.videoUrl});
//
//   @override
//   State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
// }
//
// class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
//   YoutubePlayerController? _youtubeController;
//   bool _isYouTube = false;
//   bool _isError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initializePlayer();
//   }
//
//   void initializePlayer() {
//     try {
//       // Check if it's a YouTube URL
//       String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
//
//       if (videoId != null) {
//         _isYouTube = true;
//         _youtubeController = YoutubePlayerController(
//           initialVideoId: videoId,
//           flags: const YoutubePlayerFlags(
//             autoPlay: false,
//             mute: false,
//             loop: true,
//           ),
//         );
//       } else {
//         _isError = true;
//       }
//       setState(() {});
//     } catch (e) {
//       print("Video initialization error: $e");
//       setState(() { _isError = true; });
//     }
//   }
//
//   @override
//   void dispose() {
//     _youtubeController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isError) {
//       return Container(
//         height: 250,
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.videocam_off, color: Colors.grey, size: 50),
//               const SizedBox(height: 10),
//               Text(
//                 "Video not available",
//                 style: TextStyle(color: Colors.grey[400]),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (_isYouTube && _youtubeController != null) {
//       return YoutubePlayer(
//         controller: _youtubeController!,
//         showVideoProgressIndicator: true,
//         progressIndicatorColor: Colors.red,
//         progressColors: const ProgressBarColors(
//           playedColor: Colors.red,
//           handleColor: Colors.redAccent,
//         ),
//       );
//     }
//
//     return Container(
//       height: 250,
//       color: Colors.black,
//       child: const Center(child: CircularProgressIndicator()),
//     );
//   }
// }



///urrl

//
// class ExerciseVideoPlayer extends StatelessWidget {
//   final String videoUrl;
//
//   const ExerciseVideoPlayer({super.key, required this.videoUrl});
//
//   Future<void> _launchVideo() async {
//     final Uri url = Uri.parse(videoUrl);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _launchVideo,
//       child: Container(
//         height: 250,
//         color: Colors.black,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Show thumbnail if possible
//             if (videoUrl.contains('youtube'))
//               Image.network(
//                 _getYouTubeThumbnail(videoUrl),
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(color: Colors.black),
//               ),
//             // Play button overlay
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.3),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.play_arrow,
//                 color: Colors.white,
//                 size: 60,
//               ),
//             ),
//             // Tap to play text
//             Positioned(
//               bottom: 20,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   "Tap to play video",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getYouTubeThumbnail(String url) {
//     String? videoId = _extractYouTubeId(url);
//     if (videoId != null) {
//       return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
//     }
//     return '';
//   }
//
//   String? _extractYouTubeId(String url) {
//     RegExp regExp = RegExp(
//       r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
//       caseSensitive: false,
//     );
//     Match? match = regExp.firstMatch(url);
//     return match?.group(1);
//   }
// }