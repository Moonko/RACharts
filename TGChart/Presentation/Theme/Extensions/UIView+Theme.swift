import UIKit

extension UIView {

    private var backgroundColorBlock: PaletteBlock {
        return PaletteBlock(id: "background_color") { [weak self] color in
            self?.backgroundColor = color as? UIColor
        }
    }

    var backgroundPalette: Palette? {
        get {
            return palettes[backgroundColorBlock]
        }
        set {
            palettes[backgroundColorBlock] = newValue
            backgroundColor = newValue?.typedCurrent()
        }
    }

    private var tintColorBlock: PaletteBlock {
        return PaletteBlock(id: "tint_color") { [weak self] color in
            self?.tintColor = color as? UIColor
        }
    }

    var tintColorPalette: Palette? {
        get {
            return palettes[tintColorBlock]
        }
        set {
            palettes[tintColorBlock] = newValue
            tintColor = newValue?.typedCurrent()
        }
    }
}
