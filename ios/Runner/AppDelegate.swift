import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    lazy var flutterEngine = FlutterEngine(name: "main_engine")

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ✅ Start Flutter Engine
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)

        // ✅ FORCE LIGHT MODE (Fix black UI issue)
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}