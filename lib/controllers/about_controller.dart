import 'package:get/get.dart';
import 'dart:async'; // Required for the Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutController extends GetxController {
  // --- STATIC DATA ---
  final String name = "Coach Brisley";
  final String title = "Certified Master Trainer, Nurse & Life Coach";

  final List<String> imageUrls = [
    "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
    "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
  ];

  final List<String> bioParagraphs = [
    "My fitness journey goes way back two Decades ago in Africa at my mom's kitchen. As a young kid, I struggled with depression...",
    "My only inspiration was my uncle, who I considered then buff and strong, was my biggest inspiration.",
    "Personally, physically, and mentally, I have made some breakthroughs and transitions over the years...",
    "Professionally: I have helped thousands of clients from different walks of life...",
    "I ask you to give me 12 weeks of your time, and I will transform your body beyond your wildest dreams.",
    "Thank you."
  ];

  // --- SLIDER LOGIC ---
  late PageController pageController;
  var currentPage = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);

    // Start the auto-scroll timer
    _startAutoScroll();
  }

  @override
  void onClose() {
    // Clean up to prevent memory leaks
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  // Logic to move the slider automatically
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (currentPage.value < imageUrls.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0; // Loop back to start
      }

      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Called when user swipes manually
  void onPageChanged(int index) {
    currentPage.value = index;
  }
}