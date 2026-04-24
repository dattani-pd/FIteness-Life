import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controllers/controller.dart';

// Ensure this import is correct

import 'package:flutter/material.dart';
import 'package:get/get.dart';



// ==========================================
// CONNECTED APPS MENU SCREEN (Direct Connection)
// ==========================================
class ConnectedAppsMenuScreen extends StatelessWidget {
  const ConnectedAppsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitbitController = Get.put(FitbitController());

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Connected Apps',
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            // 1. Fitbit Item (Direct Connection)
            Obx(() => _buildSimpleAppItem(
              icon: Icons.blur_on,
              name: "Fitbit",
              iconColor: Colors.teal,
              textColor: textColor,
              isConnected: fitbitController.isConnected.value,
              isLoading: fitbitController.isLoading.value,
              onTap: () {
                if (fitbitController.isConnected.value) {
                  // Show disconnect confirmation
                  _showDisconnectDialog(context, fitbitController);
                } else {
                  // Connect directly
                  //fitbitController.connectFitbit();
                  _showHealthDisclosure(context, fitbitController);
                }
              },
            )),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(height: 1, color: dividerColor),
            ),

            // // 2. Google Fit / Health Connect Item
            // _buildSimpleAppItem(
            //   icon: Icons.favorite,
            //   name: "Google Fit / Health Connect",
            //   iconColor: Colors.red,
            //   textColor: textColor,
            //   isConnected: false,
            //   isLoading: false,
            //   onTap: () {
            //     Get.snackbar(
            //       'Coming Soon',
            //       'Google Fit integration will be available soon',
            //       backgroundColor: Colors.orange,
            //       colorText: Colors.white,
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  void _showHealthDisclosure(BuildContext context, FitbitController controller) {
    final bool isDark = Get.isDarkMode;

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Data Usage Disclosure",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fitness Is Life requires access to your Fitbit data to provide the following features:",
              style: TextStyle(color: isDark ? Colors.grey : Colors.black87),
            ),
            const SizedBox(height: 15),
            _bulletPoint("Heart Rate", "To monitor intensity during workouts.", isDark),
            _bulletPoint("Weight & Height", "To calculate BMI and track physical goals.", isDark),
            _bulletPoint("Activity", "To sync your daily steps and calories.", isDark),
            const SizedBox(height: 15),
            Text(
              "This data is used only for your personal dashboard and is not shared with third parties.",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Deny", style: TextStyle(color: Colors.red.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            onPressed: () {
              Get.back();
              controller.connectFitbit();
            },
            child: const Text("Agree & Continue"),
          ),
        ],
      ),
    );
  }


  Widget _bulletPoint(String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.teal.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                children: [
                  TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc, style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAppItem({
    required IconData icon,
    required String name,
    required Color iconColor,
    required Color textColor,
    required bool isConnected,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            // Icon
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            // Status Indicator
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isConnected)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: Colors.grey.shade600, size: 24),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, FitbitController controller) {
    final bool isDark = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Disconnect Fitbit?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to disconnect your Fitbit account?',
          style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.disconnect();
            },
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

