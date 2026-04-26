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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let controller = FlutterViewController(engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)

        // Full-screen window — fixes the black bars on iOS 26
        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.rootViewController = controller
        newWindow.makeKeyAndVisible()
        self.window = newWindow
    }
}
