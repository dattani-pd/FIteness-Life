import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_life/screen/home/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller.dart';
import '../../controllers/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure this is imported
import 'package:firebase_auth/firebase_auth.dart';

import '../exercises/new_ra.dart';
import '../screen.dart'; // Make sure this is imported


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ⬇️ IMPORT YOUR CONTROLLERS & SCREENS ⬇️
import '../../controllers/controller.dart';
import '../../services/user_assignment_service.dart';


class HomeScreen extends GetView<HomeController> {
  static const pageId = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Theme Colors
    final isDark = Get.isDarkMode;
    final primaryBlack = isDark ? Colors.white : const Color(0xFF000000);
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    // const primaryRed = Color(0xFF8B0000); // Keeping red consistent as brand color

    return Scaffold(
      backgroundColor: scaffoldBg, // ✅ Dynamic BG
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: scaffoldBg, // ✅ Dynamic AppBar BG
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlack), // ✅ Dynamic Icon Color
        title: Text(
            "FITNESS IS LIFE",
            style: TextStyle(color: primaryBlack, fontWeight: FontWeight.w900)
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF8B0000)),
              onPressed: controller.logout
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() => Text(
                    "Hello, ${controller.userName.value.isEmpty ? 'User' : controller.userName.value}",
                    style: TextStyle(color: primaryBlack, fontSize: 24, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(width: 10),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.userRole.value == 'user' ? Colors.transparent : const Color(0xFF8B0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      controller.userRole.value.toUpperCase(),
                      style: TextStyle(
                          color: controller.userRole.value == 'user' ? Colors.transparent : Colors.white,
                          fontSize: 10, fontWeight: FontWeight.bold
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              Obx(() {
                switch (controller.userRole.value) {
                  case 'admin':
                    return _buildAdminContent(context); // Pass context for theme
                  case 'trainer':
                    return _buildTrainerContent(context); // Pass context for theme
                  default:
                    return _buildUserContent(context); // Pass context for theme
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Get.isDarkMode;
    final drawerBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Drawer(
      backgroundColor: drawerBg, // ✅ Dynamic Drawer BG
      width: MediaQuery.of(context).size.width * 0.65,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.close, size: 28, color: textColor), // ✅ Dynamic Close Icon
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(height: 10),

              _buildDrawerItem("Home", textColor, onTap: () => Get.back()),

              _buildDrawerItem("About", textColor, onTap: () {
                Get.back();
                Get.toNamed(AboutScreen.pageId);
              }),

              if(controller.userRole.value != 'admin')
                 _buildDrawerItem("Plans", textColor, onTap: () {
                  Get.back();
                  Get.toNamed(PlanScreen.pageId);
                 }),


              _buildDrawerItem("Nutrition", textColor, onTap: () {
                Get.back();
                Get.to(() => const NutritionScreen());
              }),

              _buildDrawerItem("WorkOut", textColor, onTap: () {
                Get.back();
                final HomeController homeController = Get.find<HomeController>();
                if (homeController.userRole.value == 'user') {
                  Get.to(() => const WorkoutPlansListScreen());
                } else {
                  Get.to(() => const MuscleWikiProScreen());
                }
              }),

              _buildDrawerItem("Health", textColor, onTap: () {
                Get.back();
                Get.to(() => const HealthScreen());
              }),


              Obx(() {
                if (controller.userRole.value == 'admin') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text("ADMIN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      _buildDrawerItem("Client", textColor, onTap: () {
                        Get.back();
                        Get.to(() => const UserListScreen(role: 'user'));
                      }),
                      _buildDrawerItem("Trainers", textColor, onTap: () {
                        Get.back();
                        Get.to(() => const UserListScreen(role: 'trainer'));
                      }),
                    ],
                  );
                }
                else if ( controller.userRole.value == 'trainer' && controller.isAccountApproved.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 20),
                      const Text("TRAINER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      _buildDrawerItem("Add Exercise", textColor, onTap: () {
                        Get.back();
                        Get.to(() => const AddExerciseScreen());
                      }),
                      _buildDrawerItem("View All Exercises", textColor, onTap: () {
                        Get.back();
                        Get.to(() => const AllExercisesScreen());
                      }),
                    ],
                  );
                }

                return const SizedBox.shrink();
              }),

              const Spacer(),

              Divider(color: isDark ? Colors.grey.shade700 : Colors.grey),
              const SizedBox(height: 10),

              _buildSmallDrawerItem("Profile", textColor, onTap: () { Get.to(() => const MyProfileDetailScreen());}),
              _buildSmallDrawerItem("Terms", textColor, onTap: () { Get.to(() => const TermsConditionsScreen());}),
              _buildSmallDrawerItem("Contact", textColor, onTap: ()async {

                String url = "https://fitnessislife.fitbudd.com/";
                if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              }),

              const SizedBox(height: 20),

              InkWell(
                onTap: controller.logout,
                child: const Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, Color color, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color, // ✅ Dynamic Text Color
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallDrawerItem(String title, Color color, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade800, // ✅ Dynamic Small Text
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent(BuildContext context) {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Obx(() {
      bool isTrainer = controller.userRole.value == 'trainer';
      bool isUser = controller.userRole.value == 'user';
      bool showSuspended = isTrainer && !controller.isAccountApproved.value;
      bool showPendingUser = isUser && !controller.isAccountApproved.value;

      if (showSuspended) {
        return _buildRestrictedView("Account Pending", "Your trainer account is under review.");
      }
      if (showPendingUser) {
        return _buildRestrictedView(
          "Account Pending",
          "Your account is pending admin approval. You will get access once an admin assigns you a trainer and approves your account.",
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Visibility(
          // //   visible: controller.userRole.value == 'user',
          // //   child: Container(
          // //     padding: const EdgeInsets.all(20),
          // //     decoration: BoxDecoration(
          // //         color: isDark ? const Color(0xFF1E1E1E) : Colors.black, // ✅ Dynamic Card BG
          // //         borderRadius: BorderRadius.circular(20)
          // //     ),
          // //     child: Column(
          // //       children: [
          // //         const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // //           Text("Weekly Goal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          // //           Text("0%", style: TextStyle(color: Colors.red)),
          // //         ]),
          // //         const SizedBox(height: 10),
          // //         LinearProgressIndicator(value: 0.01, color: Colors.red, backgroundColor: Colors.grey[800]),
          // //       ],
          // //     ),
          // //   ),
          // // ),
          //
          // const SizedBox(height: 20),
          _buildExercisePreviewGrid(context), // Pass context
          const SizedBox(height: 25),

          // --- HEADER WITH VIEW ALL ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LIVE SESSIONS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), // ✅ Dynamic
              ),
              TextButton(
                onPressed: () => Get.to(() =>  AllMeetingsScreen()),
                child: const Text("View All", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // --- FILTERED LIST (Only Upcoming) ---
          Obx(() {
            var list = controller.upcomingClasses;

            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100], // ✅ Dynamic
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text("No upcoming classes scheduled.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var meeting = list[index];

                // 1. DATE TIME CALCULATION
                String dateTimeStr = "Coming Soon";
                if (meeting['startTime'] != null) {
                  try {
                    DateTime date = (meeting['startTime'] as Timestamp).toDate();

                    String amPm = date.hour >= 12 ? 'PM' : 'AM';
                    int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
                    String minute = date.minute.toString().padLeft(2, '0');
                    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

                    dateTimeStr = "${date.day} ${months[date.month - 1]} • $hour:$minute $amPm";
                  } catch (e) {
                    dateTimeStr = "Invalid Date";
                  }
                }

                return GestureDetector(
                  onTap: () => controller.joinLiveClass(meeting['meetingLink']),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        // Calendar Icon Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 👇 2. UPDATED ROW (અહીં સુધારો કર્યો છે)
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled, size: 14, color: Colors.greenAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateTimeStr, // ✅ "UPCOMING" ની જગ્યાએ વેરીએબલ મૂક્યો
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              Text(meeting['title'] ?? "No Title",
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Trainer: ${meeting['trainerName'] ?? 'Unknown'}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 20),
         ///temp hide
          // Row(
          //   children: [
          //     _buildStatCard(context, "Workouts", "${controller.workoutsCompleted}", Icons.fitness_center, Colors.orange),
          //     const SizedBox(width: 15),
          //     _buildStatCard(context, "Kcal", "${controller.caloriesBurned}", Icons.local_fire_department, Colors.red),
          //   ],
          // ),
        ],
      );
    });
  }

  Widget _buildExercisePreviewGrid(BuildContext context) {
    final MuscleWikiController muscleController = Get.put(MuscleWikiController());
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Popular Workouts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), // ✅ Dynamic
            ),
            TextButton(
              onPressed: () {
                final HomeController homeController = Get.find<HomeController>();
                if (homeController.userRole.value == 'user') {
                  Get.to(() => const WorkoutPlansListScreen());
                } else {
                  Get.to(() => const MuscleWikiProScreen());
                }
              },
              child: const Text("View All", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
        const SizedBox(height: 10),

        Obx(() {
          if (muscleController.isLoading.value && muscleController.exercises.isEmpty) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Colors.red),
            );
          }

          if (muscleController.exercises.isEmpty) {
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: Text("No workouts available right now.", style: TextStyle(color: textColor)),
            );
          }

          var previewList = muscleController.visibleExercises.take(4).toList();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              final ex = previewList[index];

              return GestureDetector(
                onTap: () => Get.to(() => ChewieDetailScreen(
                  exercise: ex,
                  //apiKey: muscleController.apiKey,
                  genderPreference: "Both",
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // ✅ Dynamic Card BG
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.shade200, // ✅ Dynamic Shadow
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      )
                    ],
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Image
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[100],
                            child: Image.network(
                              ex.getCategoryImage(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.fitness_center,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Exercise Info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ex.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: textColor, // ✅ Dynamic Text
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                  ex.category.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAdminContent(BuildContext context) {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "ADMIN CONTROL PANEL",
            style: TextStyle(color: Color(0xFF8B0000), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)
        ),
        const SizedBox(height: 20),

        // Admin Buttons
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            icon: const Icon(Icons.add_box),
            label: const Text("CREATE NEW MEETING"),
            onPressed: () => Get.to(() => const CreateMeetingScreen()),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            _buildStatCard(context, "Total Users", "${controller.totalUsers}", Icons.group, Colors.blue, onTap: () => Get.to(() => const UserListScreen(role: 'user'))),
            const SizedBox(width: 15),
            _buildStatCard(context, "Trainers", "${controller.totalTrainers}", Icons.sports_gymnastics, Colors.orange, onTap: () => Get.to(() => const UserListScreen(role: 'trainer'))),
          ],
        ),

        Obx(() {
          if (controller.pendingTrainers.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pending Approvals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)), // ✅ Dynamic
                    Text(
                        "${controller.pendingTrainers.length} Pending",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ),
                  ]
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.pendingTrainers.length,
                itemBuilder: (context, index) {
                  var data = controller.pendingTrainers[index];
                  return Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50], // ✅ Dynamic
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.orange)),
                      title: Text(data['email'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)), // ✅ Dynamic
                      subtitle: Text("Trainer Request", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                        onPressed: () => controller.approveTrainer(data.id),
                        child: const Text("Approve", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
        Obx(() {
          if (controller.pendingUsers.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pending Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  Text(
                    "${controller.pendingUsers.length} Pending",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.pendingUsers.length,
                itemBuilder: (context, index) {
                  var doc = controller.pendingUsers[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String userId = doc.id;
                  String emailRaw = data['email']?.toString() ?? '';
                  String email = emailRaw.trim().isEmpty ? 'No email' : emailRaw.trim();
                  String name = data['name']?.toString() ?? (email != 'No email' ? email.split('@').first : 'User');
                  final userEmailForApproval = (email.isEmpty || email == 'No email') ? null : email;
                  return Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.2), child: const Icon(Icons.person_outline, color: Colors.blue)),
                      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      subtitle: Text(email, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                        onPressed: () => _showApproveUserTrainerPicker(context, userId, name, email, userEmailForApproval),
                        child: const Text("Approve", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
        const SizedBox(height: 30),
        const Divider(color: Colors.black26, thickness: 1),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.add, color: textColor), // ✅ Dynamic
            label: Text("ADD NEW EXERCISE", style: TextStyle(color: textColor)), // ✅ Dynamic
            onPressed: () => Get.to(() => const AddExerciseScreen()),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isDark ? Colors.grey : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "LIVE SESSIONS",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), // ✅ Dynamic
            ),
            TextButton(
              onPressed: () => Get.to(() =>  AllMeetingsScreen()),
              child: const Text("View All", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // 👇 UPDATED LIST WITH DATE TIME LOGIC
        Obx(() {
          var list = controller.upcomingClasses;
          if (list.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text("No upcoming classes scheduled.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey)),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              var meeting = list[index];

              // ✅ DATE TIME LOGIC
              String dateTimeStr = "Coming Soon";
              if (meeting['startTime'] != null) {
                try {
                  DateTime date = (meeting['startTime'] as Timestamp).toDate();
                  String amPm = date.hour >= 12 ? 'PM' : 'AM';
                  int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
                  String minute = date.minute.toString().padLeft(2, '0');
                  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                  dateTimeStr = "${date.day} ${months[date.month - 1]} • $hour:$minute $amPm";
                } catch (e) {
                  dateTimeStr = "Invalid Date";
                }
              }

              return GestureDetector(
                onTap: () => controller.joinLiveClass(meeting['meetingLink']),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_filled, size: 14, color: Colors.greenAccent),
                                const SizedBox(width: 6),
                                Text(dateTimeStr, style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(meeting['title'] ?? "No Title", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Trainer: ${meeting['trainerName'] ?? 'Unknown'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 15),
        const TrainerAssignmentsWidget(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTrainerContent(BuildContext context) {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    return Obx(() {
      if (!controller.isAccountApproved.value) {
        return _buildRestrictedView("Account Pending", "Your trainer account is under review.");
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              "TRAINER PANEL",
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              icon: const Icon(Icons.add_box),
              label: const Text("CREATE NEW MEETING"),
              onPressed: () => Get.to(() => const CreateMeetingScreen()),
            ),
          ),
          // -----------------------

          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(context, "Client",
                  "${controller.activeStudents}",
                  Icons.people,
                  Colors.blue,
                onTap: () => Get.to(() => const UserListScreen(role: 'user')),
              ),
              const SizedBox(width: 15),
              _buildStatCard(context, "Classes", "${controller.classesGiven}", Icons.check_circle, Colors.green,
                onTap: () => Get.to(() =>  AllMeetingsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Divider(color: isDark ? Colors.grey.shade800 : Colors.black26, thickness: 1),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LIVE SESSIONS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), // ✅ Dynamic
              ),
              TextButton(
                onPressed: () => Get.to(() =>  AllMeetingsScreen()),
                child: const Text("View All", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // 👇 UPDATED LIST WITH DATE TIME LOGIC
          Obx(() {
            var list = controller.upcomingClasses;
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text("No upcoming classes scheduled.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var meeting = list[index];

                // ✅ DATE TIME LOGIC
                String dateTimeStr = "Coming Soon";
                if (meeting['startTime'] != null) {
                  try {
                    DateTime date = (meeting['startTime'] as Timestamp).toDate();
                    String amPm = date.hour >= 12 ? 'PM' : 'AM';
                    int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
                    String minute = date.minute.toString().padLeft(2, '0');
                    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    dateTimeStr = "${date.day} ${months[date.month - 1]} • $hour:$minute $amPm";
                  } catch (e) {
                    dateTimeStr = "Invalid Date";
                  }
                }

                return GestureDetector(
                  onTap: () => controller.joinLiveClass(meeting['meetingLink']),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled, size: 14, color: Colors.greenAccent),
                                  const SizedBox(width: 6),
                                  Text(dateTimeStr, style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(meeting['title'] ?? "No Title", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Trainer: ${meeting['trainerName'] ?? 'Unknown'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 10),
          const TrainerAssignmentsWidget(),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  Widget _buildRestrictedView(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 60, color: Colors.red.shade800),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(color: Colors.red.shade900, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "$message\n\nPlease contact support.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: controller.logout,
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }

  void _showApproveUserTrainerPicker(BuildContext context, String userId, String userName, String displayEmail, String? userEmailForLookup) {
    final isDark = Get.isDarkMode;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.75;
        return SizedBox(
          height: sheetHeight,
          child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      const SizedBox(height: 16),
                      Text("Approve a trainer first, then you can assign users.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }
              return _ApproveUserAssignTrainerContent(
                userId: userId,
                userName: userName,
                userEmail: userEmailForLookup,
                trainers: trainers,
                textColor: textColor,
                onSuccess: () {
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final isDark = Get.isDarkMode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // ✅ Dynamic BG
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.grey.shade100, blurRadius: 10)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), // ✅ Dynamic
              Text(title, style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade500)), // ✅ Dynamic
            ],
          ),
        ),
      ),
    );
  }
}



/// Content for Approve User bottom sheet: trainer dropdown + Confirm Assignment (with validation and loading).
class _ApproveUserAssignTrainerContent extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userEmail;
  final List<Map<String, dynamic>> trainers;
  final Color textColor;
  final VoidCallback onSuccess;

  const _ApproveUserAssignTrainerContent({
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.trainers,
    required this.textColor,
    required this.onSuccess,
  });

  @override
  State<_ApproveUserAssignTrainerContent> createState() => _ApproveUserAssignTrainerContentState();
}

class _ApproveUserAssignTrainerContentState extends State<_ApproveUserAssignTrainerContent> {
  String? _selectedTrainerId;
  String? _selectedTrainerName;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.textColor;
    final trainers = widget.trainers;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text("Assign trainer to ${widget.userName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text("Select a trainer to approve this user", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTrainerId,
            decoration: InputDecoration(
              labelText: "Trainer",
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            hint: Text("Select a trainer", style: TextStyle(color: textColor)),
            items: trainers.map<DropdownMenuItem<String>>((t) {
              String name = t['name']?.toString().trim() ?? '';
              final String email = t['email']?.toString() ?? '';
              if (name.isEmpty && email.isNotEmpty) name = email.split('@').first;
              if (name.isEmpty) name = 'Trainer';
              final String id = t['id']?.toString() ?? '';
              return DropdownMenuItem(value: id, child: Text(name, style: TextStyle(color: textColor)));
            }).toList(),
            onChanged: _isLoading
                ? null
                : (String? value) {
                    if (value == null) return;
                    final t = trainers.cast<Map<String, dynamic>?>().firstWhere((e) => e!['id'] == value, orElse: () => null);
                    String name = t != null ? (t['name']?.toString().trim() ?? '') : '';
                    if (name.isEmpty && t != null) name = (t['email']?.toString() ?? '').split('@').first;
                    if (name.isEmpty) name = 'Trainer';
                    setState(() {
                      _selectedTrainerId = value;
                      _selectedTrainerName = name;
                    });
                  },
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedTrainerId != null && _selectedTrainerName != null
                    ? () => _confirmAssignment()
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("Confirm Assignment"),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmAssignment() async {
    if (_selectedTrainerId == null || _selectedTrainerName == null) return;
    setState(() => _isLoading = true);
    try {
      final homeController = Get.find<HomeController>();
      await homeController.approveUser(
        userId: widget.userId,
        trainerId: _selectedTrainerId!,
        trainerName: _selectedTrainerName!,
        userEmail: widget.userEmail,
      );
      if (mounted) widget.onSuccess();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}


class TrainerAssignmentsWidget extends StatefulWidget {
  const TrainerAssignmentsWidget({super.key});

  @override
  State<TrainerAssignmentsWidget> createState() => _TrainerAssignmentsWidgetState();
}

class _TrainerAssignmentsWidgetState extends State<TrainerAssignmentsWidget> {
  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isDark = Get.isDarkMode;

    if (currentUid == null) {
      return const SizedBox.shrink();
    }

    // Admin: show all users (role == 'user'). Trainer: show only assigned clients (assignedTrainerId == currentUid)
    final String role = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().userRole.value
        : 'user';
    final bool isAdmin = role == 'admin';

    final Stream<QuerySnapshot> stream = isAdmin
        ? FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots()
        : FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .where('assignedTrainerId', isEqualTo: currentUid)
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {

        // ડેટા લોડ થાય ત્યાં સુધી લોડિંગ બતાવો
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        final users = snapshot.data?.docs ?? [];
        final int clientCount = users.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // ✅ HEADER (Count અપડેટ થશે)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(isDark ? 0.1 : 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CLIENT MANAGEMENT",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Total Clients", // Active Clients ને બદલે Total Clients લખ્યું
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Client Count Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$clientCount', // ✅ કુલ સંખ્યા (4) અહીં દેખાશે
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ CLIENT LIST (બધા ક્લાયન્ટ્સ)
            if (users.isEmpty)
              _buildEmptyState(isDark)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final userId = users[index].id;

                  String userName = userData['name'] ?? '';
                  final String userEmail = userData['email'] ?? '';

                  if (userName.isEmpty && userEmail.isNotEmpty) {
                    userName = userEmail.split('@')[0];
                  }
                  if (userName.isEmpty) userName = 'Client';

                  return _UserAssignmentDropdownCard(
                    userId: userId,
                    userName: userName,
                    userEmail: userEmail,
                    isDark: isDark,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ✅ Empty State Widget
  Widget _buildEmptyState(bool isDark) {
    final Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color textColor = isDark ? Colors.white : Colors.grey.shade700;
    final Color iconColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.person_add_disabled_rounded, size: 48, color: iconColor),
          const SizedBox(height: 16),
          Text(
            "No Clients Found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            "Waiting for users to register",
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ✅ UPDATED: THEMED DROPDOWN STYLE CARD
// ==========================================
class _UserAssignmentDropdownCard extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final bool isDark; // ✅ Added theme flag

  const _UserAssignmentDropdownCard({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Colors
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color avatarBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50;
    final Color avatarBorder = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Card(
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: IconThemeData(color: textColor), // Expansion arrow color
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),

          // --- LEADING AVATAR ---
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
              border: Border.all(color: avatarBorder),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.red.shade800, // Brand color stays
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // --- USER NAME ---
          title: Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),

          // --- USER EMAIL ---
          subtitle: Text(
            userEmail,
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
            ),
          ),

          // --- EXPANDED CONTENT (THE PLANS) ---
          children: [
            Container(
              height: 1,
              color: dividerColor,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // Workout Plans Row
            _buildPlanRow(
              context: context,
              icon: Icons.fitness_center_rounded,
              title: "Workout Plans",
              color: Colors.orange,
              collection: 'workout_plan_assignments',
              onTap: () => Get.to(() => AssignedPlansScreen(
                userId: userId,     // Pass the specific user ID
                userName: userName, // Pass name for title
                planType: 'workout', // Tell it which collection to check
              )),
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Nutrition Plans Row
            _buildPlanRow(
              context: context,
              icon: Icons.restaurant_menu_rounded,
              title: "Nutrition Plans",
              color: Colors.red.shade400,
              collection: 'nutrition_plan_assignments',
              onTap: () => Get.to(() => AssignedPlansScreen(
                userId: userId,
                userName: userName,
                planType: 'nutrition',
              )),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build the Workout/Nutrition Rows inside the dropdown
  Widget _buildPlanRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required String collection,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    // 🎨 Row Colors
    final Color rowBg = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50;
    final Color rowBorder = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final Color textColor = isDark ? Colors.white : Colors.black87; // Darker text for light mode
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color chevronColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('assignedUsers', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.data?.docs.length ?? 0;
        List<String> names = [];
        if (snapshot.hasData) {
          names = snapshot.data!.docs
              .map((d) => (d.data() as Map<String, dynamic>)['planName'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .take(2)
              .toList();
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rowBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rowBorder),
            ),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15), // Slightly more opaque for visibility
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          // Count Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: count > 0 ? color : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (names.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          names.join(", "),
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18, color: chevronColor),
              ],
            ),
          ),
        );
      },
    );
  }
}