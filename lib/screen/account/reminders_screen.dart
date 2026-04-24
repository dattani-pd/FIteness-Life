import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/controller.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reminders_controller.dart';
import '../../services/notification_service.dart';
import '../screen.dart'; // Adjust import path


class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RemindersController());


    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color sectionColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color activeSwitch = isDark ? Colors.greenAccent : Colors.green;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Reminders', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Fitness", sectionColor),
            const SizedBox(height: 10),

            _buildReminderTile(
              context,
              title: "Daily Workout",
              icon: Icons.fitness_center,
              isEnabled: controller.workoutEnabled,
              time: controller.workoutTime,
              activeColor: activeSwitch,
              cardBg: cardBg,
              textColor: textColor,
              onToggle: () => controller.toggleReminder('workout', controller.workoutEnabled, RemindersController.WORKOUT_ID, "Workout Time! 💪", "Time to crush your fitness goals!", controller.workoutTime.value),
              onTimeTap: () => controller.pickTime(context, 'workout', controller.workoutTime, RemindersController.WORKOUT_ID, "Workout Time! 💪", "Time to crush your fitness goals!", controller.workoutEnabled),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("Nutrition", sectionColor),
            const SizedBox(height: 10),

            _buildReminderTile(
              context,
              title: "Breakfast",
              icon: Icons.free_breakfast_outlined,
              isEnabled: controller.breakfastEnabled,
              time: controller.breakfastTime,
              activeColor: activeSwitch,
              cardBg: cardBg,
              textColor: textColor,
              onToggle: () => controller.toggleReminder('breakfast', controller.breakfastEnabled, RemindersController.BREAKFAST_ID, "Breakfast Time 🍳", "Start your day with a healthy meal!", controller.breakfastTime.value),
              onTimeTap: () => controller.pickTime(context, 'breakfast', controller.breakfastTime, RemindersController.BREAKFAST_ID, "Breakfast Time 🍳", "Start your day with a healthy meal!", controller.breakfastEnabled),
            ),
            const SizedBox(height: 12),

            _buildReminderTile(
              context,
              title: "Lunch",
              icon: Icons.lunch_dining_outlined,
              isEnabled: controller.lunchEnabled,
              time: controller.lunchTime,
              activeColor: activeSwitch,
              cardBg: cardBg,
              textColor: textColor,
              onToggle: () => controller.toggleReminder('lunch', controller.lunchEnabled, RemindersController.LUNCH_ID, "Lunch Time 🥗", "Refuel your body for the afternoon.", controller.lunchTime.value),
              onTimeTap: () => controller.pickTime(context, 'lunch', controller.lunchTime, RemindersController.LUNCH_ID, "Lunch Time 🥗", "Refuel your body for the afternoon.", controller.lunchEnabled),
            ),
            const SizedBox(height: 12),

            _buildReminderTile(
              context,
              title: "Dinner",
              icon: Icons.dinner_dining_outlined,
              isEnabled: controller.dinnerEnabled,
              time: controller.dinnerTime,
              activeColor: activeSwitch,
              cardBg: cardBg,
              textColor: textColor,
              onToggle: () => controller.toggleReminder('dinner', controller.dinnerEnabled, RemindersController.DINNER_ID, "Dinner Time 🍲", "Eat light and sleep tight.", controller.dinnerTime.value),
              onTimeTap: () => controller.pickTime(context, 'dinner', controller.dinnerTime, RemindersController.DINNER_ID, "Dinner Time 🍲", "Eat light and sleep tight.", controller.dinnerEnabled),
            ),

            const SizedBox(height: 30),
            // ================== HYDRATION SECTION ==================
            _buildSectionHeader("Hydration", sectionColor),
            const SizedBox(height: 10),

            // 💧 WATER
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.local_drink, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Drink Water", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text("Remind me every:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.hydrationEnabled.value,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          controller.toggleHydration();
                        },
                      )
                    ],
                  ),

                  // 👇 NEW: DROPDOWN FOR INTERVAL SELECTION
                  if (controller.hydrationEnabled.value) ...[
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Frequency:", style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14)),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(0.3))
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.hydrationInterval.value,
                              dropdownColor: cardBg,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 30, child: Text("30 Mins")),
                                DropdownMenuItem(value: 60, child: Text("1 Hour")),
                                DropdownMenuItem(value: 90, child: Text("1.5 Hours")),
                                DropdownMenuItem(value: 120, child: Text("2 Hours")),
                                DropdownMenuItem(value: 180, child: Text("3 Hours")),
                              ],
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  controller.updateHydrationInterval(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            )),

            const SizedBox(height: 30),

            Obx(() {
              // 1. Get role from Controller (which got it from AppConstants)
              String role = controller.userRole.value;

              // 2. Check Role
              if (role == 'admin' || role == 'trainer') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const SendNotificationScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.redAccent.withOpacity(0.2)
                              : Colors.redAccent,
                          foregroundColor: isDark
                              ? Colors.redAccent
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isDark
                                ? const BorderSide(color: Colors.redAccent)
                                : BorderSide.none,
                          ),
                        ),
                        icon: const Icon(Icons.campaign_outlined),
                        label: const Text(
                          "SEND BROADCAST ALERT",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink(); // Hide if user
              }
            }),

            const SizedBox(height: 50), // Extra space at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(title.toUpperCase(), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2));
  }

  Widget _buildReminderTile(BuildContext context, {required String title, required IconData icon, required RxBool isEnabled, required RxString time, required VoidCallback onToggle, required VoidCallback onTimeTap, required Color cardBg, required Color textColor, required Color activeColor}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isEnabled.value ? activeColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: isEnabled.value ? activeColor : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: isEnabled.value ? onTimeTap : null,
                  child: Row(
                    children: [
                      Text(time.value, style: TextStyle(color: isEnabled.value ? activeColor : Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (isEnabled.value) ...[const SizedBox(width: 6), Icon(Icons.edit, size: 14, color: activeColor.withOpacity(0.5))]
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled.value,
            onChanged: (val) => onToggle(),
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.4),
          )
        ],
      ),
    ));
  }
}