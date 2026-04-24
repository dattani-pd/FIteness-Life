import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  String id;
  String name;
  String muscleGroup; // e.g., Chest, Legs, Cardio
  String videoUrl;    // URL to YouTube or Firebase Storage
  String instructions;
  String createdBy;   // Trainer ID or 'admin'

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.videoUrl,
    required this.instructions,
    required this.createdBy,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'videoUrl': videoUrl,
      'instructions': instructions,
      'createdBy': createdBy,
    };
  }

  // Create from Firestore
  factory ExerciseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExerciseModel(
      id: docId,
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      instructions: map['instructions'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}


// ==========================================
// WORKOUT PLAN MODEL (Same as before)
// ==========================================

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final String createdBy;
  final DateTime createdAt;
  /// Plan price for display and WooCommerce sync (e.g. "29" or "0").
  final String price;
  /// Plan duration value (e.g. "4" for 4 weeks).
  final String duration;
  /// Plan duration unit (e.g. "Weeks", "Days", "Months", "Years").
  final String durationUnit;
  /// WooCommerce product ID when synced; null if not yet created on website.
  final String? wooProductId;
  /// Image URL for the plan (saved in Firestore, used for WooCommerce sync and display).
  final String? imageUrl;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.createdBy,
    required this.createdAt,
    this.price = '0',
    this.duration = '0',
    this.durationUnit = 'Weeks',
    this.wooProductId,
    this.imageUrl,
  });

  factory WorkoutPlan.fromFirestore(Map<String, dynamic> data, String id) {
    final exercisesData = data['exercises'] as List<dynamic>? ?? [];

    return WorkoutPlan(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      exercises: exercisesData.map((e) => WorkoutExercise.fromMap(e)).toList(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: data['price']?.toString() ?? '0',
      duration: data['duration']?.toString() ?? '0',
      durationUnit: data['durationUnit']?.toString() ?? 'Weeks',
      wooProductId: data['wooProductId']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
    );
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final String difficulty;
  final int sets;
  final int reps;
  final int rest;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.difficulty,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> data) {
    return WorkoutExercise(
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      sets: data['sets'] ?? 3,
      reps: data['reps'] ?? 12,
      rest: data['rest'] ?? 60,
    );
  }

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
