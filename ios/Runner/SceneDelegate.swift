import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let controller = FlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )

        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = .light
        }

        controller.view.backgroundColor = .white
        controller.view.isOpaque = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = controller
        window.backgroundColor = UIColor.white
        window.isOpaque = true
        window.makeKeyAndVisible()

        self.window = window
    }
}
