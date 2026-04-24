import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/controller.dart';
import '../../model/model.dart';
import '../screen.dart';

class BloodPressureScreen extends StatelessWidget {
  const BloodPressureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BloodPressureController());
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Blood Pressure Tracker", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // --- HEADER & ADD BUTTON ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: subText, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Log readings from your cuff monitor.",
                        style: TextStyle(color: subText, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddLogBottomSheet(context, controller, isDark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Log New Reading", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Get.to(() =>  BluetoothScanScreen()), // 👈 Navigate to Scan
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.bluetooth, color: Colors.blue),
              label: const Text("Sync via Bluetooth", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),
          ),
          const SizedBox(height: 10),

          // --- HISTORY LIST ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.bpHistory.isEmpty) {
                return Center(child: Text("No logs yet", style: TextStyle(color: subText)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.bpHistory.length,
                itemBuilder: (context, index) {
                  final log = controller.bpHistory[index];
                  return _buildBPCard(log, cardBg, textColor, subText);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBPCard(BloodPressureModel log, Color cardBg, Color textColor, Color subText) {
    Color statusColor = Colors.green;
    if (log.systolic >= 140 || log.diastolic >= 90) statusColor = Colors.red;
    else if (log.systolic >= 120) statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          // BP Values
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${log.systolic}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    " / ${log.diastolic}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: subText),
                  ),
                  const SizedBox(width: 4),
                  Text("mmHg", style: TextStyle(fontSize: 12, color: subText)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.favorite, size: 14, color: Colors.red.shade300),
                  const SizedBox(width: 4),
                  Text("${log.pulse} BPM", style: TextStyle(fontSize: 12, color: subText)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Status Badge & Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, hh:mm a').format(log.date),
                style: TextStyle(fontSize: 11, color: subText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddLogBottomSheet(BuildContext context, BloodPressureController controller, bool isDark) {
    final Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Log Blood Pressure", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInput(controller.systolicController, "Systolic (Top)", "120", textColor)),
                const SizedBox(width: 15),
                Expanded(child: _buildInput(controller.diastolicController, "Diastolic (Bottom)", "80", textColor)),
              ],
            ),
            const SizedBox(height: 15),
            _buildInput(controller.pulseController, "Pulse (BPM) - Optional", "72", textColor),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.saveBPLog(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Save Record", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, String hint, Color textColor) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}