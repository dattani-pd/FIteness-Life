import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/constant.dart';
import '../../controllers/controller.dart';
import '../../controllers/main_navigation_controller.dart';
import '../screen.dart';
import 'package:share_plus/share_plus.dart';

// ✅ Enum to identify which question is being asked
enum QuestionType {
  coachingObjective,
  activityLevel,
  workoutLocation,
  workoutFrequency,
  dietPreference,
  injuries,
  foodAllergies,
  commitment,
}

// ==========================================
// MAIN NAVIGATION WRAPPER WITH BOTTOM NAV
// ==========================================
class MainNavigationScreen extends StatelessWidget {
  static const pageId = "/MainNavigationScreen";

  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Controllers
    final navController = Get.put(MainNavigationController());
    Get.put(HomeController());

    // Wrap Scaffold in Obx to listen to theme changes if needed,
    // but Get.changeThemeMode usually handles this globally.
    // Ensure backgroundColor uses context.theme which updates.
    final shellBg = context.theme.scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: shellBg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: shellBg,
        body: SizedBox.expand(
          child: Container(
            color: shellBg,
            child: Obx(() => _getPage(navController.currentIndex.value)),
          ),
        ),
        bottomNavigationBar: Obx(() => _buildBottomNavBar(context, navController)),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const NutritionScreen();
      case 2:
        return const MuscleWikiProScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavBar(BuildContext context, MainNavigationController controller) {
    // Listen to the current theme mode to force rebuild if Get.isDarkMode doesn't update fast enough
    // However, typically Get.isDarkMode is reactive.
    // Let's use the AppConstants observable to be sure.
    final themeMode = AppConstants.currentThemeMode.value;
    final bool isDark = themeMode == ThemeMode.dark;

    final Color barColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color shadowColor = isDark ? Colors.black26 : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, icon: Icons.home_rounded, label: 'Home', index: 0, controller: controller, isDark: isDark),
              _buildNavItem(context, icon: Icons.restaurant_menu_rounded, label: 'Meals', index: 1, controller: controller, isDark: isDark),
              _buildNavItem(context, icon: Icons.fitness_center_rounded, label: 'WorkOut', index: 2, controller: controller, isDark: isDark),
              _buildNavItem(context, icon: Icons.person_rounded, label: 'Account', index: 3, controller: controller, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required MainNavigationController controller, required bool isDark}) {
    final isSelected = controller.currentIndex.value == index;

    final Color activeColor = isDark ? Colors.white : Colors.black;
    final Color inactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24
            ),
            const SizedBox(height: 4),
            Text(
                label,
                style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500
                )
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PROFILE SCREEN (Updated for Theme)
// ==========================================

class ProfileScreen extends StatelessWidget {
  static const pageId = "/ProfileScreen";

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final user = FirebaseAuth.instance.currentUser;

    // Use Obx to rebuild when theme changes
    return Obx(() {
      final bool isDark = AppConstants.currentThemeMode.value == ThemeMode.dark;

      final Color backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
      final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
      final Color textColor = isDark ? Colors.white : Colors.black;
      final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      final Color iconColor = isDark ? Colors.white70 : Colors.black87;

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text('Account', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          iconTheme: IconThemeData(color: iconColor),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. USER HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200,
                            shape: BoxShape.circle
                        ),
                        child: Center(
                          child: Obx(() {
                            final name = homeController.userName.value;
                            return Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.grey.shade600
                                )
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Obx(() => Text(
                          homeController.userName.value.isNotEmpty ? homeController.userName.value : 'User',
                          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)
                      )),
                      const SizedBox(height: 4),
                      // Email
                      Text(user?.email ?? '', style: TextStyle(color: subTextColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      // Role Badge
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: homeController.userRole.value == 'user' ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: homeController.userRole.value == 'user' ? Colors.blue : Colors.orange),
                        ),
                        child: Text(
                          homeController.userRole.value.toUpperCase(),
                          style: TextStyle(
                            color: homeController.userRole.value == 'user' ? Colors.blue : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),

                // 2. ACTIVE PLAN CARD (Dynamic Count)
                Obx(() {
                  if (homeController.userRole.value == 'user') {
                    final bool isDark = AppConstants.currentThemeMode.value == ThemeMode.dark;

                    return FutureBuilder<int>(
                        future: _calculateActivePlans(), // 👇 આ ફંક્શન નીચે બનાવવાનું છે
                        builder: (context, snapshot) {
                          String displayText = "Loading...";
                          if (snapshot.hasData) {
                            int count = snapshot.data!;
                            displayText = count > 0 ? "$count Active Plans" : "No Active Plan";
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300)
                            ),
                            child: Center(
                                child: Text(
                                    displayText,
                                    style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                    )
                                )
                            ),
                          );
                        }
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 20),

                // 3. MENU LIST
                Container(
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
                  ),
                  child: Obx(() {
                    final isClient = homeController.userRole.value == 'user';

                    return Column(
                      children: [
                        const SizedBox(height: 10),

                        // --- MY PROFILE ---
                        _buildMenuItem(context, isDark, icon: Icons.person_outline, title: 'My Profile', hasRedDot: true, onTap: () => Get.to(() => const MyProfileDetailScreen())),
                        _buildDivider(isDark),

                        // --- REMINDERS ---
                        _buildMenuItem(context, isDark, icon: Icons.notifications_none_outlined, title: 'Reminders',
                            onTap: () => Get.to(() => const RemindersScreen())
                        ),
                        _buildDivider(isDark),
                        // _buildMenuItem(context, isDark, icon: Icons.watch_outlined, title: 'Connected Apps', onTap: () => Get.to(() => const ConnectedAppsMenuScreen())),

                        // 🔒 CLIENT ONLY SECTION
                        if (isClient) ...[
                          _buildMenuItem(context, isDark, icon: Icons.straighten_outlined, title: 'Measurement Goals',
                              onTap: () {
                             Get.to(() => const MeasurementGoalsScreen());
                          }),
                          _buildDivider(isDark),
                          _buildMenuItem(context, isDark, icon: Icons.watch_outlined, title: 'Connected Apps', onTap: () => Get.to(() => const ConnectedAppsMenuScreen())),
                          _buildDivider(isDark),
                          _buildMenuItem(context, isDark, icon: Icons.speed_outlined, title: 'Unit System',
                              onTap: () => Get.to(() => const UnitSystemScreen())),
                          const SizedBox(height: 16),
                          Container(height: 8, color: isDark ? Colors.black : Colors.grey.shade100),
                        ],

                        // --- ABOUT COACH ---
                        _buildMenuItem(context, isDark, icon: Icons.person_pin_outlined, title: 'About Coach Brisley', onTap: () => Get.toNamed(AboutScreen.pageId)),
                        _buildDivider(isDark),

                        // --- EXPLORE PLANS ---
                        _buildMenuItem(context, isDark, icon: Icons.article_outlined, title: 'Explore Plans', onTap: () => Get.toNamed(PlanScreen.pageId)),
                        const SizedBox(height: 16),
                        Container(height: 8, color: isDark ? Colors.black : Colors.grey.shade100),

                        // 🔒 SHARE SECTION
                        if (isClient) ...[
                          _buildMenuItem(context, isDark, icon: Icons.star_outline, title: 'Rate App', onTap: () async {
                            String url = Platform.isAndroid ? "https://play.google.com/store/apps/details?id=com.fitnessislife.app" : "https://apps.apple.com/us/app/fitness-is-life/id6503628361";
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          }),
                          _buildDivider(isDark),
                          _buildMenuItem(context, isDark, icon: Icons.share_outlined, title: 'Tell a Friend',
                              onTap: () {
                            Share.share("Hey, I am getting in shape by working out with Fitness is Life. Check it out!\n\nWebsite: https://fitnessislife.org");
                          }),
                          const SizedBox(height: 16),
                          Container(height: 8, color: isDark ? Colors.black : Colors.grey.shade100),
                        ],

                        // --- APPEARANCE ---
                        _buildMenuItem(
                            context,
                            isDark,
                            icon: Icons.wb_sunny_outlined,
                            title: 'Appearance',
                            trailing: Text(
                                AppConstants.currentThemeMode.value == ThemeMode.dark ? 'DARK' : 'LIGHT',
                                style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)
                            ),
                            onTap: () => _showThemeBottomSheet(context)
                        ),
                        _buildDivider(isDark),

                        // --- CHANGE PASSWORD ---
                        _buildMenuItem(context, isDark, icon: Icons.lock_outline, title: 'Change Password',
                            onTap: () => Get.to(() => const ChangePasswordScreen())
                        ),
                        _buildDivider(isDark),

                        // --- LOGOUT ---
                        _buildMenuItem(
                          context,
                          isDark,
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () {
                            Get.dialog(AlertDialog(
                              backgroundColor: cardColor,
                              title: Text('Logout', style: TextStyle(color: textColor)),
                              content: Text('Are you sure you want to logout?', style: TextStyle(color: subTextColor)),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                ElevatedButton(onPressed: () { Get.back(); homeController.logout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Logout', style: TextStyle(color: Colors.white))),
                              ],
                            ));
                          },
                        ),
                        const SizedBox(height: 40),
                        Text('Powered By Fitbudd', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text('V.3.6.53', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                        const SizedBox(height: 30),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMenuItem(BuildContext context, bool isDark, {required IconData icon, required String title, Widget? trailing, bool hasRedDot = false, required VoidCallback onTap}) {
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color iconColor = isDark ? Colors.white70 : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  if (hasRedDot) ...[
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null) Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
        padding: const EdgeInsets.only(left: 64),
        child: Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final bool isDark = AppConstants.currentThemeMode.value == ThemeMode.dark;
    final Color bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color text = isDark ? Colors.white : Colors.black;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Appearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
              const SizedBox(height: 20),
              ListTile(
                title: Center(child: Text("Light", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text))),
                onTap: () { AppConstants.setTheme("light"); Get.back(); },
              ),
              Divider(height: 1, color: Colors.grey.shade800),
              ListTile(
                title: Center(child: Text("Dark", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text))),
                onTap: () { AppConstants.setTheme("dark"); Get.back(); },
              ),
              Divider(height: 1, color: Colors.grey.shade800),
              ListTile(
                title: const Center(child: Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red))),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _calculateActivePlans() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 0;

      // 1. Get Assigned Plans
      final assignedSnap = await FirebaseFirestore.instance
          .collection('workout_plan_assignments')
          .where('assignedUsers', arrayContains: uid)
          .get();

      return assignedSnap.docs.length;
    } catch (e) {
      return 0;
    }
  }
}


class MyProfileDetailScreen extends StatefulWidget {
  const MyProfileDetailScreen({super.key});

  @override
  State<MyProfileDetailScreen> createState() => _MyProfileDetailScreenState();
}

class _MyProfileDetailScreenState extends State<MyProfileDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          profileData = doc.data() ?? {};
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() => isLoading = false);
    }
  }

  // Helper to calculate Age
  int _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 0;
    try {
      final parts = dob.split(' ');
      if (parts.length != 3) return 0;

      final day = int.parse(parts[0]);
      final monthStr = parts[1];
      final year = int.parse(parts[2]);

      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthIndex = months.indexOf(monthStr) + 1;
      if (monthIndex == 0) return 0;

      final birthDate = DateTime(year, monthIndex, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  // Helper to calculate BMI
  String _calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return "0.0";
    double heightM = heightCm / 100;
    double bmi = weightKg / (heightM * heightM);
    return bmi.toStringAsFixed(1);
  }

  Widget _buildAssignedTrainerRow(String? trainerName, Color textColor, Color subText, Color containerBg) {
    final hasTrainer = trainerName != null && trainerName.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: subText.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              hasTrainer ? Icons.person_pin : Icons.person_off_outlined,
              size: 24,
              color: hasTrainer ? Colors.blue : subText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your trainer',
                    style: TextStyle(color: subText, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasTrainer ? trainerName.trim() : 'No trainer assigned',
                    style: TextStyle(
                      color: hasTrainer ? textColor : subText,
                      fontSize: 16,
                      fontWeight: hasTrainer ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    // ✅ THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color avatarBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200;
    final Color containerBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    // Data Prep
    final dob = profileData['dob'] as String?;
    final gender = profileData['gender'] as String? ?? 'Male';
    final height = (profileData['height'] as num?)?.toDouble() ?? 0.0;
    final weight = (profileData['weight'] as num?)?.toDouble() ?? 0.0;

    final age = _calculateAge(dob);
    final genderShort = gender.isNotEmpty ? gender[0].toUpperCase() : 'M';
    final bmi = _calculateBMI(height, weight);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text('My Profile', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.edit, color: textColor),
              onPressed: () async {
                await Get.to(() => const EditProfileScreen());
                _loadProfileData();
              }
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                child: Center(
                  child: Obx(() {
                    final name = homeController.userName.value;
                    return Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade600)
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Obx(() => Text(
                  homeController.userName.value.isNotEmpty ? homeController.userName.value : 'User',
                  style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)
              )),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$age ($genderShort)', style: TextStyle(color: subText, fontSize: 15)),
                  const SizedBox(width: 16),
                  Text('${height.toInt()} cm', style: TextStyle(color: subText, fontSize: 15)),
                  const SizedBox(width: 16),
                  Text('${weight.toInt()} kg', style: TextStyle(color: subText, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),

              // BMI Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BMI', style: TextStyle(color: subText, fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(bmi, style: TextStyle(color: subText, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          border: Border.all(color: subText, width: 1.5),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text('Status', style: TextStyle(color: subText, fontSize: 13, fontWeight: FontWeight.w500))
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Assigned trainer (for regular users only)
              if (profileData['role'] == 'user') ...[
                _buildAssignedTrainerRow(
                  profileData['assignedTrainerName']?.toString(),
                  textColor,
                  subText,
                  containerBg,
                ),
                const SizedBox(height: 24),
              ],

              // /// Complete Profile Button
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24),
              //   child: InkWell(
              //     onTap: () => Get.snackbar('Complete Profile', 'This feature will be available soon', backgroundColor: Colors.blue, colorText: Colors.white),
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //       decoration: BoxDecoration(color: containerBg, borderRadius: BorderRadius.circular(30)),
              //       child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Text('Complete Profile', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
              //             const SizedBox(width: 8),
              //             Icon(Icons.chevron_right, color: subText)
              //           ]
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 32),

              // Questions List
              _buildProfileQuestion('What is your coaching objective?', profileData['coachingObjective'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('What is your normal level of activity?', profileData['activityLevel'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('Where do you typically workout?', profileData['workoutLocation'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('How many days in a week would you like to workout?', profileData['workoutFrequency'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('What is your diet preference?', profileData['dietPreference'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('Do you have any injuries or physical limitations?', profileData['injuries'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('Do you have any food allergies?', profileData['foodAllergies'] ?? 'Not Answered', textColor, subText, dividerColor),
              _buildProfileQuestion('Will you be committed towards your fitness journey?', profileData['commitmentLevel'] != null ? '${(profileData['commitmentLevel'] as num).toInt()}%' : 'Not Answered', textColor, subText, dividerColor),

              const SizedBox(height: 24),

              // Delete Account
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: () => Get.dialog(
                      AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                          title: Text('Delete Account', style: TextStyle(color: textColor)),
                          content: Text('Are you sure you want to delete your account? This action cannot be undone.', style: TextStyle(color: subText)),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () { Get.back(); Get.snackbar('Account Deletion', 'This feature will be available soon', backgroundColor: Colors.red, colorText: Colors.white); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete', style: TextStyle(color: Colors.white)))
                          ]
                      )
                  ),
                  child: Row(
                      children: [
                        Text('Delete My Account', style: TextStyle(color: subText, fontSize: 15)),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: subText, size: 20)
                      ]
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileQuestion(String question, String answer, Color textColor, Color subTextColor, Color dividerColor) {
    return InkWell(
      onTap: () async {
        QuestionType? type;
        if (question.contains('coaching objective')) type = QuestionType.coachingObjective;
        else if (question.contains('normal level of activity')) type = QuestionType.activityLevel;
        else if (question.contains('typically workout')) type = QuestionType.workoutLocation;
        else if (question.contains('many days')) type = QuestionType.workoutFrequency;
        else if (question.contains('diet preference')) type = QuestionType.dietPreference;
        else if (question.contains('injuries')) type = QuestionType.injuries;
        else if (question.contains('food allergies')) type = QuestionType.foodAllergies;
        else if (question.contains('committed')) type = QuestionType.commitment;

        if (type != null) {
          await Get.to(() => ProfileQuestionScreen(questionType: type!));
          _loadProfileData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: dividerColor, width: 1))),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question, style: TextStyle(color: subTextColor, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(answer, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))
                    ]
                )
            ),
            Icon(Icons.chevron_right, color: subTextColor, size: 24),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DYNAMIC PROFILE QUESTION SCREEN (HANDLES ALL QUESTIONS)
// ==========================================

class ProfileQuestionScreen extends StatefulWidget {
  final QuestionType questionType;

  const ProfileQuestionScreen({super.key, required this.questionType});

  @override
  State<ProfileQuestionScreen> createState() => _ProfileQuestionScreenState();
}

class _ProfileQuestionScreenState extends State<ProfileQuestionScreen> {
  String? selectedOption;
  TextEditingController textController = TextEditingController();
  double sliderValue = 50;
  bool isLoading = true;
  bool isSaving = false;

  // 1. Map Enum to Firebase Field Name
  String get firebaseField {
    switch (widget.questionType) {
      case QuestionType.coachingObjective: return 'coachingObjective';
      case QuestionType.activityLevel: return 'activityLevel';
      case QuestionType.workoutLocation: return 'workoutLocation';
      case QuestionType.workoutFrequency: return 'workoutFrequency';
      case QuestionType.dietPreference: return 'dietPreference';
      case QuestionType.injuries: return 'injuries';
      case QuestionType.foodAllergies: return 'foodAllergies';
      case QuestionType.commitment: return 'commitmentLevel';
    }
  }

  // 2. Map Enum to Display Question
  String get questionText {
    switch (widget.questionType) {
      case QuestionType.coachingObjective: return 'What is your coaching objective?';
      case QuestionType.activityLevel: return 'What is your normal level of activity?';
      case QuestionType.workoutLocation: return 'Where do you typically workout?';
      case QuestionType.workoutFrequency: return 'How many days in a week would you like to workout?';
      case QuestionType.dietPreference: return 'What is your diet preference?';
      case QuestionType.injuries: return 'Do you have any injuries or physical limitations?';
      case QuestionType.foodAllergies: return 'Do you have any food allergies?';
      case QuestionType.commitment: return 'Will you be committed towards your fitness journey?';
    }
  }

  // 3. Map Enum to Options (if multiple choice)
  List<String>? get options {
    switch (widget.questionType) {
      case QuestionType.coachingObjective: return ['Strength training', 'Improve endurance', 'Improve athletic skills', 'Weight gain', 'Weight loss'];
      case QuestionType.activityLevel: return ['Sedentary: No exercise and have a desk job', 'Exercise 1-3 days per week', 'Exercise 3-5 days per week', 'Exercise 6-7 days per week', 'Exercise multiple times a day or have a physically challenging job'];
      case QuestionType.workoutLocation: return ['Home', 'Gym', 'Outdoors'];
      case QuestionType.workoutFrequency: return ['Once a week', '2-3 days a week', '4-5 days a week', '6-7 days a week'];
      case QuestionType.dietPreference: return ['Standard', 'Pescetarian', 'Vegetarian', 'Lacto-vegetarian', 'Ovo-vegetarian', 'Vegan'];
      default: return null;
    }
  }

  // Helpers to determine UI type
  bool get isTextInput => widget.questionType == QuestionType.injuries || widget.questionType == QuestionType.foodAllergies;
  bool get isSlider => widget.questionType == QuestionType.commitment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey(firebaseField)) {
        final value = doc.data()![firebaseField];
        setState(() {
          if (isTextInput) textController.text = value ?? '';
          else if (isSlider) sliderValue = (value as num).toDouble();
          else selectedOption = value;
        });
      } else if (options != null && options!.isNotEmpty) {
        // Default select first option if nothing saved
        selectedOption = options!.first;
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      dynamic valueToSave = isTextInput ? textController.text.trim() : isSlider ? sliderValue : selectedOption;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        firebaseField: valueToSave,
        'lastUpdated': FieldValue.serverTimestamp()
      });

      Get.back();
      Get.snackbar('Saved', 'Your answer has been saved', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Error saving: $e');
      Get.snackbar('Error', 'Failed to save. Please try again.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color fabBg = isDark ? Colors.white : Colors.black;
    final Color fabIcon = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(textColor, cardBg, isDark),
      floatingActionButton: isSaving
          ? const CircularProgressIndicator()
          : FloatingActionButton(
        onPressed: _saveData,
        backgroundColor: fabBg,
        child: Icon(Icons.check, color: fabIcon),
      ),
    );
  }

  Widget _buildBody(Color textColor, Color cardBg, bool isDark) {
    if (isTextInput) return _buildTextInputQuestion(textColor, cardBg, isDark);
    if (isSlider) return _buildSliderQuestion(textColor, isDark);
    return _buildMultipleChoiceQuestion(textColor, cardBg, isDark);
  }

  Widget _buildMultipleChoiceQuestion(Color textColor, Color cardBg, bool isDark) {
    final Color borderColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            questionText,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: options!.length,
            itemBuilder: (context, index) {
              final isSelected = selectedOption == options![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => setState(() => selectedOption = options![index]),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? borderColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      options![index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputQuestion(Color textColor, Color cardBg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            questionText,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Enter here (or leave empty if none)',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderQuestion(Color textColor, bool isDark) {
    final Color inactiveColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color activeColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            questionText,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 4,
            ),
            child: Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => sliderValue = value),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Not sure', style: TextStyle(color: subTextColor, fontSize: 16)),
              Text('More than 100%', style: TextStyle(color: subTextColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "${sliderValue.toInt()}%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

// ==========================================
// EDIT PROFILE SCREEN
// ==========================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  String gender = 'Male';
  String dateOfBirth = '01 Jan 2000';
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nameController.text = data['name'] ?? '';
          gender = data['gender'] ?? 'Male';
          dateOfBirth = data['dob'] ?? '01 Jan 2000';
          heightController.text = data['height']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'gender': gender,
        'dob': dateOfBirth,
        'height': double.tryParse(heightController.text) ?? 0,
        'weight': double.tryParse(weightController.text) ?? 0,
      });

      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        AppConstants.setUserName(name);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().userName.value = name.isNotEmpty ? name : Get.find<HomeController>().userName.value;
      }

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color avatarBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200;
    final Color iconColor = isDark ? Colors.white : Colors.black;
    final Color buttonColor = isDark ? Colors.white : Colors.black;
    final Color buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Profile', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Stack(
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 0, right: 0,
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: isDark ? Colors.grey.shade800 : Colors.white,
                //       shape: BoxShape.circle,
                //       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                //     ),
                //     child: Icon(Icons.edit, size: 20, color: iconColor),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 40),

            // Form Fields
            _buildEditField(label: 'Name', controller: nameController, textColor: textColor, dividerColor: dividerColor),
            _buildGenderField(textColor, dividerColor, bg),
            _buildDateField(context, textColor, dividerColor),
            _buildEditField(label: 'Height', controller: heightController, suffix: 'cm', textColor: textColor, dividerColor: dividerColor),
            _buildEditField(label: 'Weight', controller: weightController, suffix: 'kg', textColor: textColor, dividerColor: dividerColor),

            const SizedBox(height: 40),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: buttonTextColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: dividerColor, width: 1))),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: textColor, fontSize: 16)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter $label',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                suffix: suffix != null
                    ? Text(suffix, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField(Color textColor, Color dividerColor, Color sheetBg) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Male', style: TextStyle(color: textColor)),
                    trailing: gender == 'Male' ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () { setState(() => gender = 'Male'); Get.back(); },
                  ),
                  ListTile(
                    title: Text('Female', style: TextStyle(color: textColor)),
                    trailing: gender == 'Female' ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () { setState(() => gender = 'Female'); Get.back(); },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: dividerColor, width: 1))),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text('Gender', style: TextStyle(color: textColor, fontSize: 16))),
            Expanded(
              child: Text(
                gender,
                textAlign: TextAlign.right,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, Color textColor, Color dividerColor) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) {
            // Force theme for DatePicker to ensure visibility
            return Theme(
              data: Get.isDarkMode ? ThemeData.dark() : ThemeData.light(),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            dateOfBirth = '${picked.day.toString().padLeft(2, '0')} ${_getMonthName(picked.month)} ${picked.year}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: dividerColor, width: 1))),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text('Date Of Birth', style: TextStyle(color: textColor, fontSize: 16))),
            Expanded(
              child: Text(
                dateOfBirth,
                textAlign: TextAlign.right,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
