import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller.dart';

class AllMeetingsScreen extends StatelessWidget {
  const AllMeetingsScreen({super.key});

  static const Color primaryRed = Color(0xFF8B0000);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("All Sessions", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Obx(() {
        if (controller.liveClasses.isEmpty) {
          return Center(
            child: Text(
              "No class history found.",
              style: TextStyle(color: subTextColor, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.liveClasses.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            var meeting = controller.liveClasses[index];

            Timestamp? ts = meeting['startTime'];
            bool isExpired = false;
            if (ts != null) {
              isExpired = ts.toDate().add(const Duration(hours: 2)).isBefore(DateTime.now());
            }

            return GestureDetector(
              onTap: () => isExpired ? null : controller.joinLiveClass(meeting['meetingLink']),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isExpired
                      ? LinearGradient(
                          colors: isDark
                              ? [Colors.grey.shade800, Colors.grey.shade700]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF8B0000), Color(0xFFA52A2A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isExpired ? Colors.grey : primaryRed).withOpacity(isDark ? 0.3 : 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isExpired ? Icons.history : Icons.videocam, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired ? "ENDED" : "UPCOMING / LIVE",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meeting['title'] ?? "Session",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            meeting['trainerName'] ?? "Trainer",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
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
