import UIKit

final class ThemeSelector {

    private static let themes: [Theme] = [
        LightTheme(),
        DarkTheme()
    ]

    static var themeName: String {
        return themes[themeIndex].name
    }

    static var nextThemeName: String {
        return themes[nextIndex].name
    }

    private(set) static var themeIndex: Int = 0

    private static var nextIndex: Int {
        let nextIndex = themeIndex + 1
        if nextIndex == themes.count {
            return 0
        }
        return nextIndex
    }

    static func chooseNextTheme() {
        themeIndex = nextIndex
        NotificationCenter.default.post(name: .themeUpdateNotificationName, object: nil)
    }

    static func animateThemeChange() {
        guard let optionalWindow = UIApplication.shared.delegate?.window,
            let window = optionalWindow,
            let snapshot = window.snapshotView(afterScreenUpdates: false) else {
                return
        }

        window.addSubview(snapshot)
        snapshot.frame = window.bounds

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                snapshot.alpha = 0
            },
            completion: { _ in
                snapshot.removeFromSuperview()
            }
        )
    }

    static func colorPalette(for key: ColorKey) -> Palette {
        return Palette(objects: themes.compactMap { $0.colors[key] })
    }

    static func statusBarPalette() -> Palette {
        return Palette(objects: themes.compactMap { $0.statusBarStyle })
    }

    static func effectPalette() -> Palette {
        return Palette(objects: themes.compactMap { $0.effect })
    }

    private init() { }
}

extension NSNotification.Name {

    static let themeUpdateNotificationName = NSNotification.Name(rawValue: "theme_update_notification_name")
}
