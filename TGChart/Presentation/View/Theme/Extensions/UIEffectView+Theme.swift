import UIKit

extension UIVisualEffectView {

    private var effectBlock: PaletteBlock {
        return PaletteBlock(id: "effect") { [weak self] effect in
            self?.effect = effect as? UIVisualEffect
        }
    }

    var effectPalette: Palette? {
        get {
            return palettes[effectBlock]
        }
        set {
            palettes[effectBlock] = newValue
            effect = newValue?.typedCurrent()
        }
    }
}
