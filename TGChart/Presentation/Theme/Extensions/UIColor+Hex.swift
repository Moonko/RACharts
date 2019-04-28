import UIKit

extension UIColor {

    static func hex(_ hex: Int) -> UIColor {
        return UIColor(
            red: CGFloat(((hex >> 16) & 0xff)) / 255,
            green: CGFloat(((hex >> 8) & 0xff)) / 255,
            blue: CGFloat((hex & 0xff)) / 255,
            alpha: 1
        )
    }
}
