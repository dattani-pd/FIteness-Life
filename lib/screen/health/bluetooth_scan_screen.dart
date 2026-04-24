import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../controllers/controller.dart';

class BluetoothScanScreen extends StatelessWidget {
  const BluetoothScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BluetoothBPController());
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    // Start scanning immediately
    controller.startScan();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: Text("Connect BP Monitor", style: TextStyle(color: textColor)),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.startScan,
          )
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Obx(() => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.withOpacity(0.1),
            child: Text(
              controller.statusMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          )),

          // Scan List
          Expanded(
            child: Obx(() {
              if (controller.scanResults.isEmpty && controller.isScanning.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.scanResults.isEmpty) {
                return Center(
                  child: Text(
                    "No devices found.\nMake sure your BP Cuff is in Pairing Mode.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.scanResults.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final result = controller.scanResults[index];
                  final device = result.device;

                  return ListTile(
                    tileColor: bg,
                    leading: const Icon(Icons.bluetooth, color: Colors.blue),
                    title: Text(device.platformName.isNotEmpty ? device.platformName : "Unknown Device", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text(device.remoteId.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => controller.connectToDevice(device),
                      child: const Text("Connect", style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
              );
            }),
          ),

          Obx(() {
            if (controller.connectedDevice.value != null) {
              return Container(
                padding: const EdgeInsets.all(20),
                color: Colors.green.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("✅ Connected to BP Monitor", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => controller.disconnect(), // 👈 Manual Disconnect
                      child: const Text("Disconnect", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink(); // Hide if not connected
            }
          }),
        ],
      ),
    );
  }
}