import UIKit

extension CALayer {

    private var backgroundColorBlock: PaletteBlock {
        return PaletteBlock(id: "layer_background_color") { [weak self] color in
            self?.setBackgroundColor((color as? UIColor))
        }
    }

    var backgroundPalette: Palette? {
        get {
            return palettes[backgroundColorBlock]
        }
        set {
            palettes[backgroundColorBlock] = newValue
            setBackgroundColor(newValue?.typedCurrent())
        }
    }

    private func setBackgroundColor(_ color: UIColor?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundColor = color?.cgColor
        CATransaction.commit()
    }
}
