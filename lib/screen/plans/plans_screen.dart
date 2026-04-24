import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/constant.dart';
import '../../controllers/controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screen.dart';
import '../../model/model.dart';

///oldw 2201

class PlanScreen extends GetView<PlanController> {
  static const pageId = "/PlanScreen";
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("My Plans", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. જો લોડિંગ ચાલુ હોય તો SHIMMER બતાવો (Spinner ની જગ્યાએ)
          if (controller.isLoading.value) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 3, // ૩ નકલી કાર્ડ બતાવો
              itemBuilder: (context, index) => _buildShimmerCard(isDark),
            );
          }

          // 2. ડેટા આવી જાય પછી લિસ્ટ બતાવો
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.plans.length,
            itemBuilder: (context, index) {
              final plan = controller.plans[index];
              return _buildPlanCard(context, plan, isDark);
            },
          );
        }),
      ),
    );
  }

  // ✨ Shimmer Effect Widget (આ નવું ફંક્શન નીચે ઉમેરો)
  Widget _buildShimmerCard(bool isDark) {
    final Color baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        height: 350, // કાર્ડ જેટલી સાઈઝ
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }


  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan, bool isDark) {
    // 🎨 Colors (Keeping your existing colors)
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color titleColor = isDark ? Colors.white : Colors.black;
    final Color descColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color featureTextColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color placeholderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color iconColor = isDark ? Colors.grey.shade600 : Colors.grey;

    // ✅ CHECK ROLE
    final String userRole = AppConstants.role; // Get current role
    final bool isUser = userRole == 'user'; // Only show buttons for 'user'

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGE SECTION
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              plan['image'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: placeholderColor,
                child: Center(child: Icon(Icons.fitness_center, size: 60, color: iconColor)),
              ),
            ),
          ),

          // 2. CONTENT SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['title'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
                ),
                const SizedBox(height: 10),
                Text(
                  plan['description'],
                  style: TextStyle(fontSize: 14, color: descColor, height: 1.5),
                ),
                const SizedBox(height: 15),
                ...List.generate(plan['features'].length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, size: 18, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(plan['features'][i], style: TextStyle(color: featureTextColor, fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. PRICE FOOTER (Button Only for Users)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price & Duration (Always Visible)
                Row(
                  children: [
                    Text(
                      plan['price'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(width: 5),
                    Text(plan['durationText'], style: TextStyle(fontSize: 14, color: descColor)),
                  ],
                ),

                // ✅ BUTTON REMOVED for Admin/Trainer
                // Only show button if role is 'user'
                if (isUser)
                  Obx(() {
                    bool isActive = controller.isPlanActive(plan);

                    return InkWell(
                      onTap: isActive
                          ? null
                          : () {
                        if (plan['priceValue'] == 0.0) {
                          controller.joinFreePlan(plan);
                        } else {
                          controller.purchasePlan(plan);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.grey.shade700
                              : (plan['priceValue'] == 0.0 ? Colors.green : Colors.red.shade800),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isActive) ...[
                              const Icon(Icons.check_circle, size: 16, color: Colors.white),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              isActive
                                  ? 'Active'
                                  : (plan['priceValue'] == 0.0 ? 'Start Free' : 'Buy Now'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


///new Approcch
// class PlanScreen extends GetView<PlanController> {
//   static const pageId = "/PlanScreen";
//   const PlanScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // 🎨 THEME COLORS
//     final bool isDark = Get.isDarkMode;
//     final Color bg = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
//     final Color appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
//     final Color textColor = isDark ? Colors.white : Colors.black;
//
//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         title: Text(
//           "Workout Plans",
//           style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: appBarBg,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: textColor),
//       ),
//       body: Stack(
//         children: [
//           Obx(() {
//             if (controller.isWorkoutLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (controller.workoutPlans.isEmpty) {
//               return Center(child: Text("No plans available", style: TextStyle(color: textColor)));
//             }
//
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: controller.workoutPlans.length,
//               itemBuilder: (context, index) {
//                 final plan = controller.workoutPlans[index];
//                 return _buildPlanCard(plan, isDark);
//               },
//             );
//           }),
//
//           // Loading Overlay for Payment
//           Obx(() {
//             if (!controller.isLoading.value) return const SizedBox.shrink();
//             return Container(
//               color: Colors.black.withOpacity(0.6),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlanCard(WorkoutPlan plan, bool isDark) {
//     final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
//     final Color textColor = isDark ? Colors.white : Colors.black87;
//     final Color subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
//
//     return Obx(() {
//       // ✅ CHECK PURCHASE STATUS
//       bool isPurchased = controller.purchasedPlanTitles.contains(plan.name.trim());
//
//       return Card(
//         margin: const EdgeInsets.only(bottom: 20),
//         color: cardBg,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: isPurchased ? const BorderSide(color: Colors.green, width: 1.5) : BorderSide.none
//         ),
//         elevation: 4,
//         child: InkWell(
//           onTap: () {
//             if (isPurchased) {
//               // ✅ OPEN DETAILS (જો ખરીદેલું હોય તો જ)
//               Get.to(() => WorkoutPlanDetailScreen(plan: plan, isReadOnly: true));
//             } else {
//               // 💳 TRIGGER PAYMENT (જો ન ખરીદેલું હોય તો)
//               controller.purchaseWorkoutPlan(plan);
//             }
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. Header with Gradient
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: isPurchased
//                         ? [Colors.green.shade800, Colors.green.shade600] // Active = Green
//                         : [Colors.red.shade900, Colors.red.shade800],    // Locked = Red
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             plan.name,
//                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '${plan.exercises.length} Exercises',
//                             style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Lock/Unlock Icon
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle
//                       ),
//                       child: Icon(
//                         isPurchased ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
//                         color: Colors.white,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//
//               // 2. Body
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Static Price Showcasing
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Price", style: TextStyle(color: subText, fontSize: 12)),
//                             const SizedBox(height: 4),
//                             Text(
//                               isPurchased ? "PAID" : "\$40.00", // 🔥 Static Price Shown Here
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: isPurchased ? Colors.green : textColor
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         // Action Button
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                           decoration: BoxDecoration(
//                             color: isPurchased ? Colors.transparent : Colors.black,
//                             border: isPurchased ? Border.all(color: Colors.green) : null,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Text(
//                             isPurchased ? "OPEN PLAN" : "BUY NOW",
//                             style: TextStyle(
//                                 color: isPurchased ? Colors.green : Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }