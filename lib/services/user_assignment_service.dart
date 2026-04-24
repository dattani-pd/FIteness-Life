import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for assigning trainers to users (Admin) and querying trainers.
class UserAssignmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Updates the user document with [assignedTrainerId] and optionally [assignedTrainerName].
  static Future<void> assignTrainerToUser({
    required String userId,
    required String trainerId,
    String? trainerName,
  }) async {
    final Map<String, dynamic> updates = {'assignedTrainerId': trainerId};
    if (trainerName != null && trainerName.isNotEmpty) {
      updates['assignedTrainerName'] = trainerName;
    }
    await _db.collection('users').doc(userId).update(updates);
  }

  /// Removes trainer assignment from a user.
  static Future<void> unassignTrainerFromUser(String userId) async {
    await _db.collection('users').doc(userId).update({
      'assignedTrainerId': FieldValue.delete(),
      'assignedTrainerName': FieldValue.delete(),
    });
  }

  /// Approve a user and assign a trainer. Updates users doc and ensures the user's UID
  /// is linked in user_purchases and workout_plan_assignments for every plan they have
  /// (so Admin list shows correct plan count). Creates one assignment document per plan.
  static Future<void> approveUser({
    required String userId,
    required String trainerId,
    required String trainerName,
    String? userEmail,
  }) async {
    final ref = _db.collection('users').doc(userId);
    final String? effectiveEmail = userEmail?.trim();
    final bool hasRealEmail = effectiveEmail != null &&
        effectiveEmail.isNotEmpty &&
        !effectiveEmail.toLowerCase().startsWith('no email');

    // ---------------------------------------------------------
    // 1. Get all purchased plans from user_purchases (by UID, then by email)
    // ---------------------------------------------------------
    List<Map<String, String>> assignments = [];
    void collectFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String purchaseId = doc.id;
        final String planId = (data['planId']?.toString().trim() ?? doc.id).trim();
        final String planName = data['planTitle']?.toString().trim() ?? data['planName']?.toString().trim() ?? '';
        if (planId.isEmpty) continue;
        assignments.add({
          'purchaseId': purchaseId,
          'planId': planId,
          'planName': planName,
        });
      }
    }

    final byUid = await _db.collection('user_purchases').doc(userId).collection('plans').get();
    collectFromSnapshot(byUid);
    if (assignments.isEmpty && hasRealEmail) {
      final normalizedEmail = effectiveEmail.trim().toLowerCase();
      final byEmail = await _db.collection('user_purchases').doc(normalizedEmail).collection('plans').get();
      collectFromSnapshot(byEmail);
    }

    // ---------------------------------------------------------
    // 2. WriteBatch: update plan-centric docs and create assignment docs
    // ---------------------------------------------------------
    if (assignments.isNotEmpty) {
      final batch = _db.batch();
      for (final a in assignments) {
        final planId = a['planId']!;
        final planName = a['planName'] ?? '';
        final purchaseId = a['purchaseId']!;

        // 2a. Ensure workout_plan_assignments doc for this plan has userId in assignedUsers (so app queries work)
        final planRef = _db.collection('workout_plan_assignments').doc(planId);
        batch.set(planRef, {
          'planId': planId,
          'planName': planName,
          'assignedUsers': FieldValue.arrayUnion([userId]),
        }, SetOptions(merge: true));

        // 2b. Create a new assignment document with userId, planId, assignedAt, status, purchaseId
        final assignmentRef = _db.collection('workout_plan_assignments').doc();
        batch.set(assignmentRef, {
          'userId': userId,
          'planId': planId,
          'assignedAt': FieldValue.serverTimestamp(),
          'status': 'active',
          'purchaseId': purchaseId,
        });
      }
      await batch.commit();
    }

    // Same for nutrition_plan_assignments if you have user_purchases for nutrition (optional).
    // For now we only handle workout plans from user_purchases.

    // ---------------------------------------------------------
    // 3. Update user profile
    // ---------------------------------------------------------
    await ref.update({
      'isApproved': true,
      'status': 'active',
      'assignedTrainerId': trainerId,
      'assignedTrainerName': trainerName,
      'isPlaceholder': false,
      'approvalDate': FieldValue.serverTimestamp(),
    });

    print("🎯 User Approved Successfully! Assignments created: ${assignments.length}");
  }

  /// Stream of all trainers (role == 'trainer'). Optionally filter by [isApproved].
  static Stream<QuerySnapshot> getTrainersStream({bool approvedOnly = true}) {
    Query<Map<String, dynamic>> q = _db
        .collection('users')
        .where('role', isEqualTo: 'trainer');
    if (approvedOnly) {
      q = q.where('isApproved', isEqualTo: true);
    }
    return q.snapshots();
  }

  /// One-time fetch of all (approved) trainers.
  static Future<List<Map<String, dynamic>>> getTrainers({bool approvedOnly = true}) async {
    Query<Map<String, dynamic>> q = _db
        .collection('users')
        .where('role', isEqualTo: 'trainer');
    if (approvedOnly) {
      q = q.where('isApproved', isEqualTo: true);
    }
    final snap = await q.get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
