import UIKit

extension CATextLayer {

    private var textColorBlock: PaletteBlock {
        return PaletteBlock(id: "layer_text_color") { [weak self] color in
            self?.foregroundColor = (color as? UIColor)?.cgColor
        }
    }

    var textColorPalette: Palette? {
        get {
            return palettes[textColorBlock]
        }
        set {
            palettes[textColorBlock] = newValue
            let color: UIColor? = newValue?.typedCurrent()
            foregroundColor = color?.cgColor
        }
    }
}
