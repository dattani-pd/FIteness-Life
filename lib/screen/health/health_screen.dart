import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/health_service_controller.dart';
import '../screen.dart';


// ==============================================================================
// HEALTH SCREEN (Themed)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthServiceController controller = Get.put(HealthServiceController());

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FA); // Slightly off-white for modern feel
    final Color surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Health Overview',
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()), // Requires intl package
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 🏃 LIVE STEPS HERO CARD (UPDATED RED) ---
          Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // 👇 ફેરફાર: આ ચોક્કસ કલર કોડ વાપરો જે તમારા સ્ક્રીનશોટ સાથે મેચ થાય છે
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.red.shade900, Colors.black]
                  : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)], // Red 700 -> Red 900
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD32F2F).withOpacity(0.4), // શેડો પણ તે જ લાલ કલરનો
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],

              ),
            // 🔴 લાલ કાર્ડની અંદરનો નવો કોડ
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end, // બધું નીચેની લાઈનમાં સીધું રહેશે
              children: [

                // 👈 ડાબી બાજુ: લખાણ અને સ્ટેપ્સ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // નાનું હેડર
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.white.withOpacity(0.8), size: 20),
                        const SizedBox(width: 8),
                        const Text("LIVE ACTIVITY", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // મોટું સ્ટેપ્સ કાઉન્ટ
                    Obx(() => Text(
                      "${controller.liveStepCount.value}",
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800, height: 1.0),
                    )),

                    const SizedBox(height: 5),

                    const Text("Steps today", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),

                // 👉 જમણી બાજુ: આઈકન અને તેની નીચે Distance
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end, // બધું જમણી બાજુ (Right Align)
                  children: [
                    // 🏃‍♂️ દોડતો માણસ (Icon)
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_run, color: Colors.white, size: 30),
                    ),

                    const SizedBox(height: 20), // વચ્ચે થોડી જગ્યા

                    // 📍 Distance Badge (હવે અહીં આઈકનની નીચે આવશે)
                    Obx(() {
                      String liveKm = (controller.liveStepCount.value * 0.000762).toStringAsFixed(2);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // જેટલું લખાણ એટલી જ જગ્યા લેશે
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                                "$liveKm km",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            ),

            const SizedBox(height: 25),

            // --- 🔗 SYNC BANNER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Health Connect", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        Text("Sync with Google Fit", style: TextStyle(color: subTextColor, fontSize: 11)),
                      ],
                    ),
                  ),
                  Obx(() => Switch.adaptive(
                    value: controller.isLinked.value,
                    onChanged: (val) => val ? controller.authorizeHealth() : controller.isLinked.value = false,
                    activeColor: Colors.redAccent,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Text("Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),

            // --- 📊 METRICS GRID ---
            Obx(()=> GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1, // Adjust card height
              children: [
                // 1. Heart Rate Card (Actionable)
                _buildMetricCard(
                  title: "Heart Rate",
                  value: "${controller.heartRate.value}",
                  unit: "bpm",
                  icon: Icons.monitor_heart,
                  color: Colors.redAccent,
                  isDark: isDark,
                  onTap: () async {
                    if (await Permission.camera.request().isGranted) {
                      Get.to(() => const ProfessionalHeartRateScreen());
                    }
                  },
                  showAddIcon: true,
                ),

                // 2. Weight Card
                _buildMetricCard(
                  title: "Weight",
                  value: "${controller.weight.value}",
                  unit: "kg",
                  icon: Icons.monitor_weight_outlined,
                  color: Colors.blueAccent,
                  isDark: isDark,
                  onTap: () {}, // Add Weight Screen navigation
                ),

                // // 3. Sleep Card
                // _buildMetricCard(
                //   title: "Sleep",
                //   value: "--", // Connect to controller.sleepHours
                //   unit: "hours",
                //   icon: Icons.bedtime_outlined,
                //   color: Colors.indigoAccent,
                //   isDark: isDark,
                //   onTap: () => Get.to(() => const SleepTrackerScreen()),
                // ),
                //
                // // 4. Blood Pressure
                // _buildMetricCard(
                //   title: "Blood Pressure",
                //   value: "Log",
                //   unit: "",
                //   icon: Icons.water_drop_outlined,
                //   color: Colors.orangeAccent,
                //   isDark: isDark,
                //   onTap: () => Get.to(() => const BloodPressureScreen()),
                // ),
              ],
            )),

            const SizedBox(height: 30),

            // --- 📜 HISTORY LIST ---
            Obx(() {
              if (!controller.isLinked.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Step History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Text("Last 30 Days", style: TextStyle(fontSize: 12, color: subTextColor)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.stepHistory.length,
                    itemBuilder: (context, index) {
                      final item = controller.stepHistory[index];
                      // 🧮 K.m logic (Steps * 0.000762)
                      int steps = item['steps'] ?? 0;
                      String km = (steps * 0.000762).toStringAsFixed(2);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45, height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                  item['day'].substring(0, 3),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['date'], style: TextStyle(color: subTextColor, fontSize: 12)),
                                  Text("${item['steps']} steps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.orange), // નાનું આઈકન
                                  const SizedBox(width: 4),
                                  Text(
                                      "$km km",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isDark ? Colors.white70 : Colors.black87
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ✨ Reusable Dashboard Card Widget
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool showAddIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (showAddIcon)
                  Icon(Icons.add_circle, color: color, size: 24)
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2D3142),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto', // Ensure generic font looks good
                        ),
                      ),
                      TextSpan(
                        text: " $unit",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}