import UIKit

extension UINavigationBar {

    private var barTintColorBlock: PaletteBlock {
        return PaletteBlock(id: "bar_tint_color") { [weak self] color in
            self?.barTintColor = color as? UIColor
        }
    }

    var barTintColorPalette: Palette? {
        get {
            return palettes[barTintColorBlock]
        }
        set {
            palettes[barTintColorBlock] = newValue
            barTintColor = newValue?.typedCurrent()
        }
    }

    private var titleColorBlock: PaletteBlock {
        return PaletteBlock(id: "title_color") { [weak self] color in
            self?.setTitleColor(color as? UIColor)
        }
    }

    var titleColorPalette: Palette? {
        get {
            return palettes[titleColorBlock]
        }
        set {
            palettes[titleColorBlock] = newValue
            setTitleColor(newValue?.typedCurrent())
        }
    }

    func setTitleColor(_ color: UIColor?) {
        if titleTextAttributes == nil {
            titleTextAttributes = [NSAttributedString.Key: Any]()
        }
        titleTextAttributes?[.foregroundColor] = color
    }
}
