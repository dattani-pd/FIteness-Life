import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_life/bindings/binding.dart';
import 'package:fitness_life/controllers/controller.dart';
import 'package:fitness_life/screen/screen.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'app_routes.dart';
import 'constant/constant.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

bool _firebaseReady = false;

// 1. BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  print('🌙 BACKGROUND MESSAGE: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep iOS in manual mode to avoid black letterboxing around safe areas.
  if (Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'channelKey1',
          channelName: 'Fitness Notifications',
          channelDescription: 'Notifications for Fitness Life',
          importance: NotificationImportance.High,
        )
      ],
      debug: true,
    );

    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    await AppConstants.loadFromPrefs();
    await AppConstants.loadTheme();

    Get.put(MuscleWikiController());
    await GetStorage.init();

    runApp(const MyApp());

  } catch (e) {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fitness Life',
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      themeMode: ThemeMode.light,
      initialRoute: SplashScreen.pageId,
      initialBinding: SplashBinding(),
      getPages: appPages,
      debugShowCheckedModeBanner: false,
      // Fills safe areas / letterboxing on all routes (e.g. iPhone notch & home indicator).
      builder: (context, child) {
        final theme = Theme.of(context);
        final bg = theme.scaffoldBackgroundColor;
        final isDark = theme.brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: bg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                isDark ? Brightness.dark : Brightness.light,
          ),
          child: ColoredBox(
            color: bg,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
