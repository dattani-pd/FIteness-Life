// import Flutter
// import FirebaseCore
// import UIKit
// import UserNotifications

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
// if FirebaseApp.app() == nil {
//             FirebaseApp.configure()
//         }

//         // Notifications callback disabled temporarily to bypass build errors
//         // FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//         //     GeneratedPluginRegistrant.register(with: registry)
//         // }

//         if #available(iOS 10.0, *) {
//             UNUserNotificationCenter.current().delegate = self
//         }
//         application.registerForRemoteNotifications()

//         GeneratedPluginRegistrant.register(with: self)
//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
// }


import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main_engine")

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Start the engine and register plugins BEFORE the scene delegate creates the window
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
