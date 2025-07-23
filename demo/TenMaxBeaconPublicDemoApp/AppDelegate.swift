import UIKit
import TenMaxBeaconSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate - application didFinishLaunchingWithOptions")

        if #available(iOS 13.0, *) {
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            let mainPageViewController = MainPageViewController()
            let navController = UINavigationController(rootViewController: mainPageViewController)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()

            AppBeaconManager.shared.initialize(with: navController)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("AppDelegate - configurationForConnecting")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("AppDelegate - didDiscardSceneSessions")
    }

    // MARK: - Compatible with iOS 12 and below

    var window: UIWindow?

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("AppDelegate - applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("AppDelegate - applicationDidBecomeActive")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("AppDelegate - applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("AppDelegate - applicationDidEnterBackground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("AppDelegate - applicationWillTerminate")
    }
}
