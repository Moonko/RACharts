import UIKit

let layerYHeight: CGFloat = 20

final class LayerY {

    var value: ChannelValue = 0 {
        didSet {
            valueLayer.string = "\(Int(value))"
        }
    }

    var separatorHeight = 1 / UIScreen.main.scale

    let valueLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.textColorPalette = .captionColor
        layer.fontSize = 12
        layer.opacity = 0
        return layer
    }()

    let separatorLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundPalette = .chartLine
        layer.opacity = 0
        return layer
    }()

    private let valueLabelSize = CGSize(width: 50, height: 15)

    init() {
        valueLayer.frame.size = valueLabelSize
    }

    func add(to toLayer: CALayer) {
        toLayer.insertSublayer(separatorLayer, at: 0)
        toLayer.addSublayer(valueLayer)
    }

    func removeFromSuperlayer() {
        valueLayer.removeFromSuperlayer()
        separatorLayer.removeFromSuperlayer()
    }

    func layoutLayers(in frame: CGRect) {
        valueLayer.position.y = frame.maxY - valueLabelSize.height - separatorHeight

        separatorLayer.frame = CGRect(
            x: 0,
            y: frame.maxY - separatorHeight,
            width: frame.width,
            height: separatorHeight
        )
    }

    func moveAndFade(in fadeIn: Bool, y: CGFloat) {
        valueLayer.opacity = fadeIn ? 1 : 0
        separatorLayer.opacity = fadeIn ? 1 : 0

        valueLayer.position.y = y + layerYHeight - 10 - separatorHeight
        separatorLayer.position.y = y + layerYHeight - separatorHeight
    }
}
