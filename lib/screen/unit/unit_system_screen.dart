
// ==========================================
// SCREEN: UI MATCHING SCREENSHOT
// ==========================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../controllers/controller.dart';



// ==========================================
// SCREEN: UI MATCHING SCREENSHOT
// ==========================================


class UnitSystemScreen extends StatelessWidget {
  const UnitSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnitSystemController());

    // 🎨 THEME SETUP
    final bool isDark = Get.isDarkMode;

    // Background Colors
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color sectionDividerColor = isDark ? Colors.black : Colors.grey.shade50;

    // Text Colors
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.black87;
    final Color iconColor = isDark ? Colors.grey.shade400 : Colors.black54;

    // Border Colors
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    // Popup Menu Color
    final Color popupBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg, // ✅ Dynamic
      appBar: AppBar(
        backgroundColor: bg, // ✅ Dynamic
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // ✅ Dynamic
          onPressed: () => Get.back(),
        ),
        title: Text(
            'Unit System',
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600) // ✅ Dynamic
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        return Column(
          children: [
            const SizedBox(height: 10),

            // --- TOP DROPDOWN (Unit: Metric) ---
            InkWell(
              onTap: () {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                showMenu(
                  context: context,
                  position: position.shift(const Offset(180, 55)),
                  color: popupBg, // ✅ Dynamic Popup Background
                  surfaceTintColor: popupBg,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // થોડું Rounded સારું લાગશે
                      side: isDark ? BorderSide(color: Colors.grey.shade800) : BorderSide.none // Dark mode માં બોર્ડર
                  ),
                  items: [
                    _buildPopupMenuItem(controller, "Metric", textColor),
                    _buildPopupMenuItem(controller, "Imperial", textColor),
                    _buildPopupMenuItem(controller, "Imperial (US)", textColor),
                    _buildPopupMenuItem(controller, "Custom", textColor),
                  ],
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                color: bg, // ✅ Dynamic
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Unit", style: TextStyle(fontSize: 16, color: subTextColor)), // ✅ Dynamic
                    Row(
                      children: [
                        Text(controller.selectedSystem.value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)), // ✅ Dynamic
                        const SizedBox(width: 8),
                        Icon(Icons.unfold_more, size: 20, color: iconColor), // ✅ Dynamic
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Grey Divider Bar
            Container(height: 10, color: sectionDividerColor), // ✅ Dynamic Divider

            // --- UNIT LIST ---
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildUnitRow("Weight", controller.weightUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Height", controller.heightUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Circumference", controller.circumferenceUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Water", controller.waterUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Food (Volume)", controller.foodVolumeUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Food (Weight)", controller.foodWeightUnit.value, textColor, subTextColor, borderColor),
                  _buildUnitRow("Distance", controller.distanceUnit.value, textColor, subTextColor, borderColor, isLast: true),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper for Popup Menu Item
  PopupMenuItem<String> _buildPopupMenuItem(UnitSystemController controller, String value, Color textColor) {
    return PopupMenuItem<String>(
      value: value,
      onTap: () => controller.setSystem(value),
      height: 48,
      child: Text(
          value,
          style: TextStyle(
              fontSize: 16,
              color: textColor, // ✅ Dynamic Text Color inside Popup
              fontWeight: FontWeight.w500
          )
      ),
    );
  }

  // Helper Widget for List Rows
  Widget _buildUnitRow(String label, String value, Color textColor, Color subTextColor, Color borderColor, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderColor, width: 1)), // ✅ Dynamic Border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: subTextColor)), // ✅ Dynamic
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)), // ✅ Dynamic
        ],
      ),
    );
  }
}