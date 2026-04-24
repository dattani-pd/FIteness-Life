import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FitbitController extends GetxController {
  var isConnected = false.obs;
  var isLoading = false.obs;

  final String clientId = "23TVW2";
  final String clientSecret = "c792be52159ddf66453424a65456c587";
  final String callbackScheme = "fitnesslife";
  final String redirectUri = "fitnesslife://callback";

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;

  // @override
  // void onInit() {
  //   super.onInit();
  //   _checkStatus();
  //   _initDeepLinkListener();
  // }
  //
  // @override
  // void onClose() {
  //   _linkSubscription?.cancel();
  //   super.onClose();
  // }
  //
  // // ✅ Listen for deep link callbacks
  // void _initDeepLinkListener() {
  //   _appLinks = AppLinks();
  //
  //   // Listen to incoming links
  //   _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
  //     if (uri != null && uri.scheme == 'fitnesslife') {
  //       print("🔗 Deep link received: $uri");
  //       _handleCallback(uri);
  //     }
  //   }, onError: (err) {
  //     print("❌ Deep link error: $err");
  //   });
  //
  //   // Check for initial link (when app starts from a link)
  //   _checkInitialLink();
  // }
  //
  // Future<void> _checkInitialLink() async {
  //   try {
  //     final uri = await _appLinks.getInitialLink();
  //     if (uri != null && uri.scheme == 'fitnesslife') {
  //       print("🔗 Initial link: $uri");
  //       _handleCallback(uri);
  //     }
  //   } catch (e) {
  //     print("❌ Initial link error: $e");
  //   }
  // }

  @override
  void onInit() {
    super.onInit();
    // ⚠️ ફેરફાર: આપણે બંને વસ્તુ એકસાથે નથી કરતા, સ્ટેપ-બાય-સ્ટેપ કરીએ છીએ
    _initController();
  }

  // 🛠️ નવું ફંક્શન: જે ક્રમમાં ચેક કરશે
  void _initController() async {
    // 1. પહેલા ચેક કરો કે યુઝર કનેક્ટેડ છે કે નહીં?
    await _checkStatus();

    // 2. લિસનર ચાલુ કરો (આ જરૂરી છે જો યુઝર ડિસ્કનેક્ટ કરીને ફરી કનેક્ટ કરે)
    _initDeepLinkListener();

    // 3. ⚠️ સૌથી મહત્વનું: જો કનેક્ટેડ ન હોય, તો જ Initial Link ચેક કરો!
    // જો કનેક્ટેડ હોય, તો જૂની લિંકને ઈગ્નોર કરો.
    if (!isConnected.value) {
      _checkInitialLink();
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  // 🛠️ _checkStatus ને Future બનાવવું પડશે જેથી આપણે 'await' કરી શકીએ
  Future<void> _checkStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data()?['fitbitConnected'] == true) {
        isConnected.value = true;
      }
    }
  }

  void _initDeepLinkListener() {
    _appLinks = AppLinks();

    // આ લિસનર ચાલુ એપમાં લિંક આવે તો પકડશે
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'fitnesslife') {
        print("🔗 Deep link received: $uri");
        _handleCallback(uri);
      }
    }, onError: (err) {
      print("❌ Deep link error: $err");
    });
  }

  Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      // ⚠️ ફરીથી ચેક: જો કનેક્ટેડ હોય તો કંઈ ન કરો
      if (isConnected.value) return;

      if (uri != null && uri.scheme == 'fitnesslife') {
        print("🔗 Initial link found: $uri");
        _handleCallback(uri);
      }
    } catch (e) {
      print("❌ Initial link error: $e");
    }
  }
  // ✅ Handle the OAuth callback
  Future<void> _handleCallback(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];

      print("================================================");
      print("📝 Callback received!");
      print("🔗 Full URI: $uri");
      print("📝 Authorization code: $code");
      print("================================================");

      if (code != null && code.isNotEmpty) {
        await _exchangeCodeForTokens(code);
      } else {
        print("⚠️ No authorization code found in callback");
        isLoading.value = false;

        // Check if user denied access
        final error = uri.queryParameters['error'];
        if (error != null) {
          print("❌ OAuth Error: $error");
          Get.snackbar(
            "Authorization Denied",
            "You need to allow access to connect Fitbit",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Authorization Failed",
            "No authorization code received from Fitbit",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print("❌ Callback parsing error: $e");
      isLoading.value = false;
    }
  }

  // ✅ Manual token exchange using HTTP
  Future<void> _exchangeCodeForTokens(String code) async {
    try {
      print("🔄 Exchanging code for tokens...");

      // Fitbit token endpoint
      final tokenUrl = Uri.parse('https://api.fitbit.com/oauth2/token');

      // Create authorization header (Basic Auth)
      final authHeader = base64Encode(utf8.encode('$clientId:$clientSecret'));

      // Make POST request
      final response = await http.post(
        tokenUrl,
        headers: {
          'Authorization': 'Basic $authHeader',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      print("📡 Token Response Status: ${response.statusCode}");
      print("📡 Token Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final userId = data['user_id'];

        print("✅ SUCCESS!");
        print("👤 User ID: $userId");
        print("🎫 Access Token: ${accessToken?.substring(0, 20)}...");

        isConnected.value = true;

        // Save to Firebase
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({
            'fitbitConnected': true,
            'fitbitUserId': userId,
            'fitbitAccessToken': accessToken,
            'fitbitRefreshToken': refreshToken,
            'connectedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print("💾 Saved to Firebase");
        }

        Get.snackbar(
          "Connected! 🎉",
          "Fitbit account linked successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        print("⚠️ Token exchange failed: ${response.body}");
        Get.snackbar(
          "Connection Failed",
          "Error: ${response.statusCode} - ${response.body}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Token exchange error: $e");
      Get.snackbar(
        "Connection Failed",
        "Error exchanging authorization code: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connectFitbit() async {
    isLoading.value = true;

    print("================================================");
    print("🚀 STARTING FITBIT CONNECTION");
    print("🆔 Client ID: $clientId");
    print("🔗 Redirect URI: $redirectUri");
    print("================================================");

    try {
      // Build authorization URL manually
      final authUrl = Uri.https('www.fitbit.com', '/oauth2/authorize', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'activity heartrate profile weight',
        'expires_in': '31536000', // 1 year
        'prompt': 'login consent',
      });

      print("🌐 Authorization URL: $authUrl");

      // Launch the URL in browser
      if (await canLaunchUrl(authUrl)) {
        final launched = await launchUrl(
          authUrl,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          print("✅ Browser launched successfully");
          print("⏳ Waiting for user to authorize...");
          // The callback will be handled by _handleCallback
        } else {
          print("❌ Failed to launch browser");
          isLoading.value = false;
          Get.snackbar(
            "Error",
            "Could not open Fitbit authorization page",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print("❌ Cannot launch URL");
        isLoading.value = false;
        Get.snackbar(
          "Error",
          "Cannot open browser",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("❌ Connection ERROR: $e");
      isLoading.value = false;

      Get.snackbar(
        "Connection Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void disconnect() async {
    isLoading.value = true;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {

        // 1. ફાયરબેઝમાંથી ટોકન મેળવો (Revoke કરવા માટે)
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final String? accessToken = userDoc.data()?['fitbitAccessToken'];

        if (accessToken != null) {
          // 2. Fitbit API ને રિવોક કરવા માટે કોલ કરો
          final authHeader = base64Encode(utf8.encode('$clientId:$clientSecret'));
          await http.post(
            Uri.parse('https://api.fitbit.com/oauth2/revoke'),
            headers: {
              'Authorization': 'Basic $authHeader',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'token': accessToken},
          );
        }

        // 3. ફાયરબેઝમાંથી ડેટા ડિલીટ કરો
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fitbitConnected': false,
          'fitbitUserId': FieldValue.delete(),
          'fitbitAccessToken': FieldValue.delete(),
          'fitbitRefreshToken': FieldValue.delete(),
        });
      }

      isConnected.value = false;

      Get.snackbar(
        "Disconnected",
        "Fitbit account unlinked",
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Disconnect error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}