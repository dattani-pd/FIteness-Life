import 'package:cloud_firestore/cloud_firestore.dart';

class BloodPressureModel {
  final String id;
  final int systolic;  // Upper number (e.g., 120)
  final int diastolic; // Lower number (e.g., 80)
  final int pulse;     // Optional pulse
  final DateTime date;

  BloodPressureModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.date,
  });

  factory BloodPressureModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BloodPressureModel(
      id: id,
      systolic: data['systolic'] ?? 0,
      diastolic: data['diastolic'] ?? 0,
      pulse: data['pulse'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'date': Timestamp.fromDate(date),
    };
  }

  // Helper to determine status
  String get status {
    if (systolic < 120 && diastolic < 80) return "Normal";
    if (systolic >= 140 || diastolic >= 90) return "High (Hypertension)";
    if (systolic >= 120 && systolic <= 129 && diastolic < 80) return "Elevated";
    return "Stage 1 High";
  }
}