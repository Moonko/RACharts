import UIKit

final class ArrowView: UIView {

    let backgroundWidth: CGFloat = 12

    let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundPalette = .arrowColor
        layer.strokeColor = nil
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        return layer
    }()

    let arrowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 2.0
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeColor = UIColor.white.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.fillColor = nil
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = true
        clipsToBounds = true

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(arrowLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = CGRect(
            origin: .zero,
            size: CGSize(width: backgroundWidth, height: bounds.height)
        )

        let arrowLayerHeight: CGFloat = 10
        arrowLayer.frame = CGRect(
            x: 4.0,
            y: bounds.height / 2 - arrowLayerHeight / 2,
            width: 3,
            height: arrowLayerHeight
        )

        let path = UIBezierPath()
        path.move(to: CGPoint(x: arrowLayer.bounds.maxX, y: arrowLayer.bounds.maxY))
        path.addLine(to: CGPoint(x: 0, y: arrowLayer.bounds.height / 2))
        path.addLine(to: CGPoint(x: arrowLayer.bounds.maxX, y: 0))
        arrowLayer.path = path.cgPath
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: -12)
        return bounds.inset(by: hitInsets).contains(point)
    }
}
