import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/controller.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateMeetingController());
    const primaryRed = Color(0xFF8B0000);

    // Theme colors (match other screens)
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;
    final Color inputFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Schedule New Class", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),

            _buildTextField(context, "Class Title", "e.g., Morning HIIT", controller.titleController, Icons.title, isDark, inputFill, borderColor, hintColor, textColor),
            const SizedBox(height: 15),

            _buildTextField(context, "Meeting Link (Zoom/Meet)", "https://zoom.us/...", controller.linkController, Icons.link, isDark, inputFill, borderColor, hintColor, textColor),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildPickerButton(
                      context,
                      label: controller.dateText,
                      icon: Icons.calendar_today,
                      onTap: () => controller.pickDate(context),
                      isDark: isDark,
                      borderColor: borderColor,
                      textColor: textColor,
                  )),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Obx(() => _buildPickerButton(
                      context,
                      label: controller.timeText,
                      icon: Icons.access_time,
                      onTap: () => controller.pickTime(context),
                      isDark: isDark,
                      borderColor: borderColor,
                      textColor: textColor,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildTextField(context, "Description (Optional)", "What will students need?", controller.descriptionController, Icons.description, isDark, inputFill, borderColor, hintColor, textColor, maxLines: 3),

            const SizedBox(height: 30),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value ? null : controller.createMeeting,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SCHEDULE CLASS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
    bool isDark,
    Color inputFill,
    Color borderColor,
    Color hintColor,
    Color textColor, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: hintColor),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
      ),
    );
  }

  Widget _buildPickerButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B0000), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
