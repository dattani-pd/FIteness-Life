import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_life/bindings/binding.dart';
import 'package:fitness_life/controllers/controller.dart';
import 'package:fitness_life/screen/screen.dart';
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

  // Enable edge-to-edge rendering so Flutter draws under status bar & home indicator
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  print("🚀 APP STARTING - Main Function Called"); // <--- LOOK FOR THIS IN LOGS

  try {
    // 2. Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _firebaseReady = true;
    print('✅ Firebase initialized');

    // 3. Initialize Awesome Notifications
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'channelKey1', // Match the key in NotificationService
            channelName: 'Fitness Notifications',
            channelDescription: 'Notifications for Fitness Life',
            defaultColor: Colors.teal,
            ledColor: Colors.red,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          )
        ],
        debug: true
    );

    // 4. Register Background Handler
    if (_firebaseReady) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // 5. Other Inits (Your existing code)
    // await sharedPreferencesHelper.getSharedPreferencesInstance(); // Uncomment if needed
    await AppConstants.loadFromPrefs().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ loadFromPrefs timeout, continuing with defaults');
      },
    );
    await AppConstants.loadTheme().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ loadTheme timeout, continuing with defaults');
      },
    );
    Get.put(MuscleWikiController());
    await GetStorage.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ GetStorage init timeout, continuing');
        return false;
      },
    );

    print("🚀 APP READY - Running App");
    runApp(const MyApp());

    // 6. Start notifications AFTER first frame (ensures Android Activity exists)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationService().init();
        print('✅ Notification Service Started');
      } catch (e) {
        print('⚠️ Notification Service init failed: $e');
      }
    });

  } catch (e) {
    print("❌ CRITICAL ERROR in main: $e");
    _firebaseReady = false;
    // Run app anyway so user is not stuck on white/black screen.
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
      theme: ThemeData.light(), // Define your Light Theme here
      darkTheme: ThemeData.dark(), // Define your Dark Theme here
      themeMode: AppConstants.currentThemeMode.value, // ✅ Apply loaded theme
      initialRoute: SplashScreen.pageId,
      initialBinding: SplashBinding(),
      getPages: appPages,
      debugShowCheckedModeBanner: false,
    );
  }
}
