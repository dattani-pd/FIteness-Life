import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import '../../../controllers/home_controller.dart';
import '../../../constant/constant.dart';
import '../../../services/user_assignment_service.dart';

class UserListScreen extends StatelessWidget {
  final String role; // 'user' or 'trainer'

  const UserListScreen({super.key, required this.role});

  static String? _getCurrentViewerRole() {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().userRole.value;
    }
    return AppConstants.role.isNotEmpty ? AppConstants.role : null;
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final title = role == 'user' ? "All Users" : "All Trainers";
    final primaryColor = role == 'user' ? Colors.blue : Colors.orange;

    // When showing users: trainers see only their assigned clients; admin sees all.
    final bool isUserList = role == 'user';
    final String? currentRole = _getCurrentViewerRole();
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool filterByAssignedTrainer = isUserList && currentRole == 'trainer' && (currentUid != null && currentUid.isNotEmpty);

    Stream<QuerySnapshot> stream;
    if (role == 'trainer') {
      stream = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .snapshots();
    } else {
      // role == 'user'
      if (filterByAssignedTrainer) {
        stream = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .where('assignedTrainerId', isEqualTo: currentUid)
            .snapshots();
      } else {
        stream = FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots();
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No $role found.",
                style: TextStyle(color: subText, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              // Prefer document ID as user id; fallback to 'uid' field (canonical Auth UID) if present
              String userId = docs[index].id;
              final String? dataUid = data['uid']?.toString().trim();
              if (dataUid != null && dataUid.isNotEmpty) {
                userId = dataUid;
              }
              String email = data['email']?.toString().trim() ?? 'No Email';
              String name = data['name']?.toString().trim() ?? 'User';
              if (name == 'User' && email != 'No Email') {
                name = email.split('@')[0];
              }

              bool isApproved = data['isApproved'] == true;
              String? assignedTrainerId = data['assignedTrainerId']?.toString();
              String? assignedTrainerName = data['assignedTrainerName']?.toString();
              final bool isAdmin = _getCurrentViewerRole() == 'admin';

              return _UserExpandableCard(
                userId: userId,
                name: name,
                email: email,
                role: role,
                isApproved: isApproved,
                primaryColor: primaryColor,
                isDark: isDark,
                assignedTrainerId: assignedTrainerId,
                assignedTrainerName: assignedTrainerName,
                isAdmin: isAdmin,
              );
            },
          );
        },
      ),
    );
  }
}


// ==========================================
// EXPANDABLE USER CARD (With Admin Switch)
// ==========================================
class _UserExpandableCard extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isApproved;
  final Color primaryColor;
  final bool isDark;
  final String? assignedTrainerId;
  final String? assignedTrainerName;
  final bool isAdmin;

  const _UserExpandableCard({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    required this.primaryColor,
    required this.isDark,
    this.assignedTrainerId,
    this.assignedTrainerName,
    this.isAdmin = false,
  });

  // 🔥 Function to Toggle Trainer Status
  void _toggleTrainerStatus(bool newValue) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'isApproved': newValue});
  }


  void _showTrainerPicker(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: UserAssignmentService.getTrainers(approvedOnly: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            }
            final trainers = snapshot.data ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Select Trainer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ),
                ListTile(
                  leading: const Icon(Icons.person_off),
                  title: Text("No trainer", style: TextStyle(color: textColor)),
                  subtitle: const Text("Remove assignment"),
                  onTap: () async {
                    try {
                      await UserAssignmentService.unassignTrainerFromUser(userId);
                      if (context.mounted) Get.back();
                      Get.snackbar("Done", "Trainer unassigned.", backgroundColor: Colors.green, colorText: Colors.white);
                    } catch (e) {
                      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                ),
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: trainers.length,
                    itemBuilder: (context, index) {
                      final t = trainers[index];
                      String trainerName = t['name']?.toString().trim() ?? '';
                      final String email = t['email']?.toString() ?? '';
                      if (trainerName.isEmpty && email.isNotEmpty) trainerName = email.split('@').first;
                      if (trainerName.isEmpty) trainerName = 'Trainer';
                      final String tid = t['id']?.toString() ?? '';
                      final bool isSelected = assignedTrainerId == tid;
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: primaryColor.withOpacity(0.2), child: Icon(Icons.person, color: primaryColor)),
                        title: Text(trainerName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: textColor)),
                        subtitle: Text(email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                        onTap: () async {
                          try {
                            await UserAssignmentService.assignTrainerToUser(userId: userId, trainerId: tid, trainerName: trainerName);
                            if (context.mounted) Get.back();
                            Get.snackbar("Done", "Assigned to $trainerName", backgroundColor: Colors.green, colorText: Colors.white);
                          } catch (e) {
                            Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildApproveUserSection(BuildContext context) {
    final Color cardBg = isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      color: cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pending approval", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 2),
              Text("Select a trainer to approve this user", style: TextStyle(fontSize: 12, color: subTextColor)),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text("Approve"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => _showApproveUserTrainerPicker(context),
          ),
        ],
      ),
    );
  }

  void _showApproveUserTrainerPicker(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: UserAssignmentService.getTrainers(approvedOnly: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            }
            final trainers = snapshot.data ?? [];
            if (trainers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("No approved trainers yet.", style: TextStyle(color: textColor)),
                    const SizedBox(height: 8),
                    Text("Approve a trainer first.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Select trainer to approve user", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: trainers.length,
                    itemBuilder: (context, index) {
                      final t = trainers[index];
                      String trainerName = t['name']?.toString().trim() ?? '';
                      final String email = t['email']?.toString() ?? '';
                      if (trainerName.isEmpty && email.isNotEmpty) trainerName = email.split('@').first;
                      if (trainerName.isEmpty) trainerName = 'Trainer';
                      final String tid = t['id']?.toString() ?? '';
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: primaryColor.withOpacity(0.2), child: Icon(Icons.person, color: primaryColor)),
                        title: Text(trainerName, style: TextStyle(color: textColor)),
                        subtitle: Text(email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        onTap: () async {
                          try {
                            final emailForLookup = (email.isEmpty || email == 'No Email') ? null : email;
                            await UserAssignmentService.approveUser(
                              userId: userId,
                              trainerId: tid,
                              trainerName: trainerName,
                              userEmail: emailForLookup,
                            );
                            if (context.mounted) Get.back();
                            Get.snackbar("Done", "User approved and assigned to $trainerName", backgroundColor: Colors.green, colorText: Colors.white);
                          } catch (e) {
                            Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAssignTrainerSection(BuildContext context) {
    final Color cardBg = isDark ? Colors.black12 : Colors.grey.shade50;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      color: cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assigned Trainer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 2),
              Text(
                assignedTrainerName != null && assignedTrainerName!.isNotEmpty ? assignedTrainerName! : "No trainer assigned",
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text("Assign Trainer"),
            onPressed: () => _showTrainerPicker(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Card(
      color: cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: isApproved
                ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                : Colors.red.withOpacity(0.1), // Red if inactive
            child: Icon(
              Icons.person,
              color: isApproved ? primaryColor : Colors.red,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email, style: TextStyle(color: subTextColor, fontSize: 12)),

              // Assigned trainer: only show for admin (trainer sees only their own assigned users, so label is redundant)
              if (role == 'user' && isAdmin && (assignedTrainerName != null && assignedTrainerName!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_pin, size: 12, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        "Trainer: $assignedTrainerName",
                        style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // User status: Pending / Active
              if (role == 'user')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.schedule,
                        size: 12,
                        color: isApproved ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isApproved ? "Status: Active" : "Status: Pending",
                        style: TextStyle(
                          color: isApproved ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Only show text status here if it's a trainer
              if (role == 'trainer')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.cancel,
                        size: 12,
                        color: isApproved ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isApproved ? "Status: Active" : "Status: Inactive",
                        style: TextStyle(
                          color: isApproved ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          children: [
            const Divider(height: 1),

            // -------------------------------------------
            // 👤 IF USER & ADMIN & PENDING: Approve (must select trainer first)
            // -------------------------------------------
            if (role == 'user' && isAdmin && !isApproved)
              _buildApproveUserSection(context),

            // -------------------------------------------
            // 👤 IF USER & ADMIN: Assign Trainer (already approved)
            // -------------------------------------------
            if (role == 'user' && isAdmin && isApproved)
              _buildAssignTrainerSection(context),



            // -------------------------------------------
            // 🏋️ IF USER: Show Assigned Plans
            // -------------------------------------------
            if (role == 'user') ...[
              _buildPurchasedPlansCount(),
              _buildAssignedPlansList("Workout Plans", "workout_plan_assignments", Icons.fitness_center, Colors.orange),
              _buildAssignedPlansList("Nutrition Plans", "nutrition_plan_assignments", Icons.restaurant_menu, Colors.green),
              const SizedBox(height: 10),
            ],

            // -------------------------------------------
            // 👮 IF TRAINER: Show Admin Switch
            // -------------------------------------------
            if (role == 'trainer')
              Container(
                color: isDark ? Colors.black12 : Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trainer Access",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isApproved ? "Trainer can log in & manage clients" : "Trainer is blocked from app",
                          style: TextStyle(fontSize: 11, color: subTextColor),
                        ),
                      ],
                    ),
                    Switch(
                      value: isApproved,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red.shade100,
                      onChanged: (val) => _toggleTrainerStatus(val),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 👇 Purchased plans count from user_purchases/{userId}/plans (UID only)
  Widget _buildPurchasedPlansCount() {
    final effectiveUid = userId.trim();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_purchases')
          .doc(effectiveUid)
          .collection('plans')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildPurchasedPlansCountRow(count);
      },
    );
  }

  Widget _buildPurchasedPlansCountRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, size: 16, color: isDark ? Colors.grey : Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            "Purchased plans: $count",
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 👇 Existing function for Users (No changes here)
  Widget _buildAssignedPlansList(String title, String collection, IconData icon, Color iconColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('assignedUsers', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: isDark ? Colors.grey : Colors.grey.shade400),
                const SizedBox(width: 10),
                Text(
                  "No $title assigned",
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          );
        }
        var docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ...docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String planName = data['planName'] ?? "Unnamed Plan";
              return ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                leading: Icon(icon, size: 18, color: iconColor),
                title: Text(planName, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13)),
                trailing: const Icon(Icons.check_circle, size: 14, color: Colors.green),
              );
            }),
          ],
        );
      },
    );
  }
}