import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    lazy var flutterEngine = FlutterEngine(name: "main_engine")

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)

        if #available(iOS 13.0, *) {
            // iOS 13+ uses SceneDelegate for window setup.
        } else {
            let controller = FlutterViewController(
                engine: flutterEngine,
                nibName: nil,
                bundle: nil
            )
            controller.view.backgroundColor = .white
            controller.view.isOpaque = true
            controller.overrideUserInterfaceStyle = .light

            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = controller
            window.backgroundColor = .white
            window.isOpaque = true
            window.makeKeyAndVisible()
            self.window = window
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
