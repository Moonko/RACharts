import UIKit

extension UITableViewCell {

    var highlightColorPalette: Palette? {
        get {
            return selectedBackgroundView?.backgroundPalette
        }
        set {
            selectedBackgroundView = UIView()
            selectedBackgroundView?.backgroundPalette = newValue
        }
    }
}
