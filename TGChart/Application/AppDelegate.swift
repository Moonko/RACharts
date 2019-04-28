import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        let chartsListController = ChartsListTableViewController()
        let navController = ThemedNavigationController(rootViewController: chartsListController)
        navController.statusBarStylePalette = Palette.statusBarStyle
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }
}

