import UIKit

extension CAShapeLayer {

    private var fillColorBlock: PaletteBlock {
        return PaletteBlock(id: "fill_color") { [weak self] color in
            self?.setFillColor((color as? UIColor))
        }
    }

    var fillColorPalette: Palette? {
        get {
            return palettes[fillColorBlock]
        }
        set {
            palettes[fillColorBlock] = newValue
            setFillColor(newValue?.typedCurrent())
        }
    }

    private func setFillColor(_ color: UIColor?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillColor = color?.cgColor
        CATransaction.commit()
    }

    private var strokeColorBlock: PaletteBlock {
        return PaletteBlock(id: "stroke_color") { [weak self] color in
            self?.setStrokeColor((color as? UIColor))
        }
    }

    var strokeColorPalette: Palette? {
        get {
            return palettes[strokeColorBlock]
        }
        set {
            palettes[strokeColorBlock] = newValue
            setStrokeColor(newValue?.typedCurrent())
        }
    }

    private func setStrokeColor(_ color: UIColor?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        strokeColor = color?.cgColor
        CATransaction.commit()
    }
}
