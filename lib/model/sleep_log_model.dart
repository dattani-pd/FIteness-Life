import 'package:cloud_firestore/cloud_firestore.dart';

class SleepLogModel {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int durationMinutes; // Total minutes slept
  final DateTime date; // The date this sleep record belongs to

  SleepLogModel({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.date,
  });

  // Convert from Firebase
  factory SleepLogModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SleepLogModel(
      id: id,
      bedTime: (data['bedTime'] as Timestamp).toDate(),
      wakeTime: (data['wakeTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Save to Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'bedTime': Timestamp.fromDate(bedTime),
      'wakeTime': Timestamp.fromDate(wakeTime),
      'durationMinutes': durationMinutes,
      'date': Timestamp.fromDate(date),
    };
  }

  // Helper to format duration (e.g., "7h 30m")
  String get formattedDuration {
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    return "${hours}h ${minutes}m";
  }
}