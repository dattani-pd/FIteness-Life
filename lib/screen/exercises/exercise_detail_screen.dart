
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:flutter/material.dart';

// Change to StatefulWidget to manage slider state
class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  // Track current slider page
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Extract Data using 'widget.exercise'
    String name = widget.exercise['name'] ?? 'Unknown Exercise';
    String target = widget.exercise['target'] ?? 'General';
    String equipment = widget.exercise['equipment'] ?? 'Body Weight';
    String difficulty = widget.exercise['difficulty'] ?? 'Beginner';
    String category = widget.exercise['category'] ?? 'Strength';
    List<dynamic> instructions = widget.exercise['instructions'] ?? [];
    List<dynamic> secondaryMuscles = widget.exercise['secondaryMuscles'] ?? [];

    // GET THE LIST OF IMAGES WE PASSED
    List<String> imageUrls = widget.exercise['imageUrls'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
            name.toUpperCase(),
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // 1. IMAGE SLIDER (CAROUSEL)
            // ========================================================
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  // Use PageView for swiping
                  child: PageView.builder(
                    itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (imageUrls.isEmpty) {
                        return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                      }
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Colors.red));
                        },
                        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                // Dots Indicator (Only show if more than 1 image)
                if (imageUrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(imageUrls.length, (index) => _buildDot(index)),
                    ),
                  ),
              ],
            ),
            // ========================================================


            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Badges ---
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _buildChip("Target: $target", Colors.blue.shade50, Colors.blue.shade800),
                      _buildChip("Equip: $equipment", Colors.orange.shade50, Colors.orange.shade800),
                      _buildChip("Level: $difficulty", Colors.purple.shade50, Colors.purple.shade800),
                      _buildChip("Type: $category", Colors.green.shade50, Colors.green.shade800),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Secondary Muscles ---
                  if (secondaryMuscles.isNotEmpty) ...[
                    const Text("Secondary Muscles", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: secondaryMuscles.map((muscle) => _buildChip(muscle.toString(), Colors.grey.shade200, Colors.grey.shade800)).toList(),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // --- Instructions ---
                  if (instructions.isNotEmpty) ...[
                    const Text("How to Perform", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step Number
                              Container(
                                width: 28, height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50, shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Text("${index + 1}", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 15),
                              // Step Text
                              Expanded(child: Text(instructions[index], style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87))),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Slider Dots
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentImageIndex == index ? 20 : 8, // Active dot is wider
      decoration: BoxDecoration(
        color: _currentImageIndex == index ? Colors.red : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Helper for Badges
  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label.toUpperCase(), style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}