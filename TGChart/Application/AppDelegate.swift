import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = AppWindow()
        let chartsListController = ChartsListTableViewController()
        let navController = ThemedNavigationController(rootViewController: chartsListController)
        navController.statusBarStylePalette = Palette.statusBarStyle
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }
}

final class AppWindow: UIWindow {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13, *) else { return }

        switch traitCollection.userInterfaceStyle {
        case .dark where ThemeSelector.themeIndex == 0,
             .light where ThemeSelector.themeIndex == 1:
            ThemeSelector.chooseNextTheme()
        default:
            return
        }
    }
}

