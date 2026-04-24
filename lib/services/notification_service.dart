import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // 👈 THIS WAS MISSING

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Channel IDs
  static const String dailyChannelId = 'daily_reminders';
  static const String dailyChannelName = 'Daily Reminders';
  bool _isInitialized = false;

  Future<void> init() async {
    // 👇 Add this check!
    // If already initialized, STOP here. Do not register listeners again.
    if (_isInitialized) {
      print("⚠️ Notification Service already initialized. Skipping.");
      return;
    }

    print('🔔 Initializing Notification Service...');

    // 1. Initialize Timezones
    tzData.initializeTimeZones();
    await _configureLocalTimeZone();

    // 2. Initialize Local Notifications
    await _initLocalNotifications();

    // 3. Request Permissions
    await _requestPermissions();

    // 4. Initialize Firebase Push
    await _initPushNotifications();

    // 5. Initialize Awesome Notifications Listeners
    await listenForMessages();

    // 👇 Mark as done so it never runs again
    _isInitialized = true;
    print('✅ Notification Service Initialized');
  }

  // ==========================================
  // ✅ HYBRID: FIREBASE -> AWESOME NOTIFICATIONS
  // ==========================================
  Future<void> listenForMessages() async {
    // This listens for Firebase messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Message Received: ${message.notification?.body}");

      // 👇 Use Awesome Notifications to show the popup
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'channelKey1', // Must match main.dart initialization
          title: message.notification?.title ?? "Fitness Life",
          body: message.notification?.body ?? "New Alert",
          notificationLayout: NotificationLayout.Default,
          bigPicture: message.notification?.android?.imageUrl,
          largeIcon: message.notification?.android?.imageUrl,
        ),
      );
    });
  }

  // ==========================================
  // INITIALIZE LOCAL NOTIFICATIONS (flutter_local_notifications)
  // ==========================================
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("🔔 Local Notification Tapped: ${details.payload}");
      },
    );
  }

  // ==========================================
  // FIREBASE INIT
  // ==========================================
  Future<void> _initPushNotifications() async {
    try {
      // Request Permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true, provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Push Permission Granted');

        // Subscribe to topic
        await _firebaseMessaging.subscribeToTopic('all_users');

        // Get Token
        final token = await _firebaseMessaging.getToken();
        print('🔥 FCM TOKEN: $token');
        if (token != null) await saveFCMTokenToFirestore(token);
      }
    } catch (e) {
      print('❌ Error initializing push: $e');
    }
  }

  Future<void> saveFCMTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // ==========================================
  // SCHEDULE DAILY NOTIFICATION (Local)
  // ==========================================
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final nextTime = _nextInstanceOfTime(time);

      // Create Channel details for Local Plugin
      const androidDetails = AndroidNotificationDetails(
        dailyChannelId,
        dailyChannelName,
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      await notificationsPlugin.zonedSchedule(
        id, title, body, nextTime,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("❌ Error scheduling: $e");
    }
  }

  // Helpers
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final locationResult = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationResult as String));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}