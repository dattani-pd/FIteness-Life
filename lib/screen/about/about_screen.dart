import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/about_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/about_controller.dart';

import '../../controllers/about_controller.dart';
import '../screen.dart';


// ==============================================================================
// ABOUT SCREEN (Themed)
// ==============================================================================


class AboutScreen extends GetView<AboutController> {
  static const pageId = "/AboutScreen";
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color bioColor = isDark ? Colors.grey[300]! : Colors.grey[800]!;
    final Color footerColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final Color placeholderBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bg,
      // Keeps the image behind the status bar
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              stops: const [0.0, 0.4],
            ),
          ),
        ),
        // Icons/Text remain white because they are over an image/dark gradient
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. SLIDER
            // ==========================================
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        controller.imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: placeholderBg,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: placeholderBg,
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                          );
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.imageUrls.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: controller.currentPage.value == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? Colors.red
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. TEXT CONTENT
            // ==========================================
            SafeArea(
              top: false, // Keep connected to image
              bottom: true, // Respect the system bottom bar
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                    const SizedBox(height: 20),

                    // Bio Text Loop
                    ...controller.bioParagraphs.map((paragraph) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          paragraph,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: bioColor,
                          ),
                        ),
                      );
                    }),

                    // ==========================================
                    // 3. TERMS & PRIVACY FOOTER
                    // ==========================================
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => const TermsConditionsScreen());
                          },
                          child: Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              color: footerColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            Get.to(() => const PrivacyPolicyScreen());
                          },
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              color: footerColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
