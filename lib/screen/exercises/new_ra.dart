// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     themeMode: ThemeMode.light,
//     home: MuscleWikiProScreen(),
//   ));
// }
//
// class MuscleWikiProScreen extends StatefulWidget {
//   const MuscleWikiProScreen({super.key});
//
//   @override
//   State<MuscleWikiProScreen> createState() => _MuscleWikiProScreenState();
// }
//
// class _MuscleWikiProScreenState extends State<MuscleWikiProScreen> with SingleTickerProviderStateMixin {
//   // ⚠️ YOUR RAPIDAPI KEY
//   final String apiKey = "8ed3afccfamsh526fb91fb118089p110fbbjsnaada4f16a265";
//
//   // CONTROLLERS
//   late TabController _tabController;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//
//   // DATA LISTS
//   List<Exercise> exercises = [];
//   List<String> categories = [];
//   List<String> muscles = [];
//
//   // STATISTICS & HEALTH
//   Map<String, dynamic>? statistics;
//   String healthStatus = "Unknown";
//
//   // STATE VARIABLES
//   bool isLoading = false;
//   bool hasMore = true;
//   int currentOffset = 0;
//   final int limit = 15;
//
//   // ✅ FIX: Default filter set to "Barbell" to prevent empty initial calls
//   String selectedFilter = "Barbell";
//   String filterType = "category"; // 'category' or 'muscle'
//   bool isSearching = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     // 1. Initial API Calls
//     fetchFilters();
//     fetchStatistics();
//     fetchHealthCheck();
//
//     // 2. Load Exercises immediately
//     fetchExercises(reset: true);
//
//     // 3. Scroll Listener for Infinite Pagination
//     _scrollController.addListener(() {
//       // Trigger load before hitting the absolute bottom (-200 pixels)
//       if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
//         if (!isLoading && hasMore && !isSearching && _tabController.index == 0) {
//           fetchExercises(loadMore: true);
//         }
//       }
//     });
//   }
//
//   // --- API 1: Fetch Exercises ---
//   Future<void> fetchExercises({bool loadMore = false, bool reset = false}) async {
//     if (isLoading) return;
//     if (loadMore && !hasMore) return;
//
//     setState(() {
//       isLoading = true;
//       if (reset) {
//         exercises.clear();
//         currentOffset = 0;
//         hasMore = true;
//         isSearching = false;
//       }
//     });
//
//     try {
//       final uri = Uri.parse('https://musclewiki-api.p.rapidapi.com/exercises');
//
//       final urlWithParams = uri.replace(queryParameters: {
//         filterType: selectedFilter.toLowerCase(),
//         'limit': '$limit',
//         'offset': '$currentOffset',
//       });
//
//       await _makeApiCall(urlWithParams);
//     } catch (e) {
//       print("Fetch Error: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- API 2: Search ---
//   Future<void> searchExercises(String query) async {
//     if (query.isEmpty) return;
//     setState(() {
//       isLoading = true;
//       exercises.clear();
//       isSearching = true;
//     });
//
//     try {
//       final uri = Uri.parse('https://musclewiki-api.p.rapidapi.com/search');
//       await _makeApiCall(uri.replace(queryParameters: {'q': query, 'limit': '20'}));
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- API 3: Workouts (Hidden Legs) ---
//   Future<void> fetchWorkoutRoutine(String type) async {
//     setState(() {
//       isLoading = true;
//       exercises.clear();
//       isSearching = true;
//     });
//     try {
//       final uri = Uri.parse('https://musclewiki-api.p.rapidapi.com/workouts/$type');
//       await _makeApiCall(uri);
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- API 4: Random Exercise ---
//   Future<void> fetchRandomExercise() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('https://musclewiki-api.p.rapidapi.com/random'),
//         headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'},
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         Exercise? randomEx;
//         if (data is List && data.isNotEmpty) {
//           randomEx = Exercise.fromJson(data[0]);
//         } else if (data is Map<String, dynamic>) {
//           randomEx = Exercise.fromJson(data);
//         }
//
//         if (randomEx != null && mounted) {
//           Navigator.push(context, MaterialPageRoute(
//               builder: (context) => ChewieDetailScreen(exercise: randomEx!, apiKey: apiKey)
//           ));
//         }
//       }
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- HELPER: Central API Caller ---
//   Future<void> _makeApiCall(Uri uri) async {
//     try {
//       final response = await http.get(uri, headers: {
//         'X-RapidAPI-Key': apiKey,
//         'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com',
//       });
//
//       if (response.statusCode == 200) {
//         final dynamic decodedData = json.decode(response.body);
//         List<dynamic> newDataList = [];
//
//         if (decodedData is Map && decodedData.containsKey('results')) {
//           newDataList = decodedData['results'];
//         } else if (decodedData is List) {
//           newDataList = decodedData;
//         }
//
//         if (newDataList.isEmpty) {
//           setState(() => hasMore = false);
//         } else {
//           setState(() {
//             exercises.addAll(newDataList.map((json) => Exercise.fromJson(json)).toList());
//             if (!isSearching) currentOffset += limit; // ✅ Increase offset for pagination
//           });
//         }
//       }
//     } catch (e) {
//       print("Network Error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // --- API: Filters, Stats, Health ---
//   Future<void> fetchFilters() async {
//     try {
//       final catResp = await http.get(Uri.parse('https://musclewiki-api.p.rapidapi.com/categories'), headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'});
//       final musResp = await http.get(Uri.parse('https://musclewiki-api.p.rapidapi.com/muscles'), headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'});
//
//       if (catResp.statusCode == 200 && musResp.statusCode == 200) {
//         setState(() {
//           categories = List<String>.from(json.decode(catResp.body));
//           muscles = List<String>.from(json.decode(musResp.body));
//           // Ensure we have a valid selection
//           if (categories.isNotEmpty && selectedFilter.isEmpty) selectedFilter = categories[0];
//         });
//       }
//     } catch (e) {}
//   }
//
//   Future<void> fetchStatistics() async {
//     try {
//       final response = await http.get(Uri.parse('https://musclewiki-api.p.rapidapi.com/statistics'), headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'});
//       if (response.statusCode == 200) setState(() => statistics = json.decode(response.body));
//     } catch (e) {}
//   }
//
//   Future<void> fetchHealthCheck() async {
//     try {
//       final response = await http.get(Uri.parse('https://musclewiki-api.p.rapidapi.com/health'), headers: {'X-RapidAPI-Key': apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'});
//       if (response.statusCode == 200) setState(() => healthStatus = json.decode(response.body)['status'] ?? "Online");
//     } catch (e) { setState(() => healthStatus = "Offline"); }
//   }
//
//   // --- UI: Stats Dialog ---
//   void _showStatsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Database Status"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Status: $healthStatus", style: TextStyle(color: healthStatus == "Online" || healthStatus == "OK" ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
//             const Divider(),
//             if (statistics != null) ...[
//               Text("Total Exercises: ${statistics!['exercises_count'] ?? 'N/A'}"),
//               const SizedBox(height: 5),
//               Text("Total Videos: ${statistics!['videos_count'] ?? 'N/A'}"),
//             ] else const Text("Loading stats..."),
//           ],
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("MuscleWiki Pro"),
//         backgroundColor: Colors.blueAccent,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: "Exercises", icon: Icon(Icons.fitness_center)),
//             Tab(text: "Workouts", icon: Icon(Icons.calendar_today)),
//           ],
//         ),
//         actions: [
//           IconButton(icon: const Icon(Icons.info_outline), onPressed: _showStatsDialog),
//           IconButton(icon: const Icon(Icons.shuffle), onPressed: fetchRandomExercise),
//         ],
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // --- TAB 1: EXERCISES ---
//           Column(
//             children: [
//               // Search Bar
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: "Search...",
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _searchController.clear();
//                         fetchExercises(reset: true);
//                         FocusScope.of(context).unfocus();
//                       },
//                     ),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                   ),
//                   onSubmitted: searchExercises,
//                 ),
//               ),
//
//               // Filter Dropdown
//               if (!isSearching)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text("Browse by:", style: TextStyle(fontWeight: FontWeight.bold)),
//                       DropdownButton<String>(
//                         value: filterType,
//                         underline: Container(),
//                         items: const [
//                           DropdownMenuItem(value: "category", child: Text("Equipment")),
//                           DropdownMenuItem(value: "muscle", child: Text("Body Part")),
//                         ],
//                         onChanged: (val) {
//                           setState(() {
//                             filterType = val!;
//                             selectedFilter = filterType == "category"
//                                 ? (categories.isNotEmpty ? categories[0] : "Barbell")
//                                 : (muscles.isNotEmpty ? muscles[0] : "Biceps");
//                             fetchExercises(reset: true);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//               // Horizontal Chips
//               if (!isSearching)
//                 Container(
//                   height: 50,
//                   margin: const EdgeInsets.only(bottom: 5),
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     itemCount: filterType == "category" ? categories.length : muscles.length,
//                     itemBuilder: (context, index) {
//                       final item = filterType == "category" ? categories[index] : muscles[index];
//                       final isSelected = item.toLowerCase() == selectedFilter.toLowerCase();
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: ChoiceChip(
//                           label: Text(item.toUpperCase()),
//                           selected: isSelected,
//                           onSelected: (bool selected) {
//                             setState(() {
//                               selectedFilter = item;
//                               fetchExercises(reset: true);
//                             });
//                           },
//                           selectedColor: Colors.blueAccent,
//                           labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//               // List View
//               Expanded(child: _buildExerciseList()),
//             ],
//           ),
//
//           // --- TAB 2: WORKOUTS ---
//           Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text("Select a Routine", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildWorkoutButton("PUSH", Colors.orange),
//                   _buildWorkoutButton("PULL", Colors.blue),
//                   // ✅ LEGS button hidden as requested
//                 ],
//               ),
//               const Divider(),
//               Expanded(child: _buildExerciseList()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWorkoutButton(String title, Color color) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
//       onPressed: () => fetchWorkoutRoutine(title.toLowerCase()),
//       child: Text(title),
//     );
//   }
//
//   Widget _buildExerciseList() {
//     if (exercises.isEmpty && !isLoading) {
//       return const Center(child: Text("No exercises found."));
//     }
//     return ListView.builder(
//       controller: _scrollController,
//       itemCount: exercises.length + 1,
//       itemBuilder: (context, index) {
//         if (index == exercises.length) {
//           return isLoading
//               ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
//               : const SizedBox.shrink();
//         }
//         final ex = exercises[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           elevation: 2,
//           child: ListTile(
//             leading: CircleAvatar(child: Text("${index + 1}")),
//             title: Text(ex.name, maxLines: 1, overflow: TextOverflow.ellipsis),
//             subtitle: Text(ex.category.toUpperCase()),
//             trailing: const Icon(Icons.play_circle_fill, color: Colors.blueAccent),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChewieDetailScreen(exercise: ex, apiKey: apiKey),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ---------------------------------------------------------------------------
// // DETAIL SCREEN & MODEL
// // ---------------------------------------------------------------------------
// class ChewieDetailScreen extends StatefulWidget {
//   final Exercise exercise;
//   final String apiKey;
//   const ChewieDetailScreen({super.key, required this.exercise, required this.apiKey});
//
//   @override
//   State<ChewieDetailScreen> createState() => _ChewieDetailScreenState();
// }
//
// class _ChewieDetailScreenState extends State<ChewieDetailScreen> {
//   VideoPlayerController? _videoPlayerController;
//   ChewieController? _chewieController;
//   bool _isLoading = true;
//   String? _fetchedImageUrl;
//   List<String> _fetchedSteps = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchedSteps = widget.exercise.steps;
//     fetchFullDetails();
//   }
//
//   Future<void> fetchFullDetails() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://musclewiki-api.p.rapidapi.com/exercises/${widget.exercise.id}'),
//         headers: {'X-RapidAPI-Key': widget.apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'},
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         String videoUrl = "";
//         String imageUrl = "";
//
//         if (json['videos'] != null && (json['videos'] as List).isNotEmpty) {
//           videoUrl = json['videos'][0]['url'];
//           imageUrl = json['videos'][0]['og_image'] ?? "";
//         } else if (json['video'] is String) {
//           videoUrl = json['video'];
//         }
//
//         if (json['steps'] != null) setState(() { _fetchedSteps = List<String>.from(json['steps']); });
//         setState(() { _fetchedImageUrl = imageUrl; });
//
//         if (videoUrl.isNotEmpty) {
//           await initializePlayer(videoUrl);
//         } else {
//           setState(() => _isLoading = false);
//         }
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> initializePlayer(String url) async {
//     try {
//       _videoPlayerController = VideoPlayerController.networkUrl(
//         Uri.parse(url),
//         httpHeaders: {'X-RapidAPI-Key': widget.apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'},
//       );
//       await _videoPlayerController!.initialize();
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController!,
//         autoPlay: true, looping: true, aspectRatio: _videoPlayerController!.value.aspectRatio,
//       );
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoPlayerController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.exercise.name), backgroundColor: Colors.blueAccent),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 250, color: Colors.black,
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                   : _chewieController != null
//                   ? Chewie(controller: _chewieController!)
//                   : const Center(child: Text("Video Unavailable", style: TextStyle(color: Colors.white))),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_fetchedImageUrl != null && _fetchedImageUrl!.isNotEmpty)
//                     Container(
//                       height: 200, width: double.infinity, margin: const EdgeInsets.only(bottom: 20),
//                       child: Image.network(
//                         _fetchedImageUrl!,
//                         fit: BoxFit.contain,
//                         headers: {'X-RapidAPI-Key': widget.apiKey, 'X-RapidAPI-Host': 'musclewiki-api.p.rapidapi.com'},
//                       ),
//                     ),
//                   const Text("Instructions:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 10),
//                   ..._fetchedSteps.map((s) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Row(children: [
//                       const Icon(Icons.check_circle, color: Colors.blue, size: 20),
//                       const SizedBox(width: 10),
//                       Expanded(child: Text(s, style: const TextStyle(fontSize: 16))),
//                     ]),
//                   )),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Exercise {
//   final int id;
//   final String name;
//   final String category;
//   final String difficulty;
//   final List<String> steps;
//
//   Exercise({required this.id, required this.name, required this.category, required this.difficulty, required this.steps});
//
//   factory Exercise.fromJson(Map<String, dynamic> json) {
//     List<String> parsedSteps = [];
//     if (json['steps'] != null) {
//       parsedSteps = List<String>.from(json['steps']);
//     }
//     return Exercise(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? "Unknown",
//       category: json['category'] ?? "",
//       difficulty: json['difficulty'] ?? "General",
//       steps: parsedSteps,
//     );
//   }
// }