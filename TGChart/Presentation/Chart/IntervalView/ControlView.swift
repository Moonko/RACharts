import UIKit

final class ControlView: UIView {

    let leftArrowView: ArrowView
    let rightArrowView: ArrowView

    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColorPalette = .arrowColor
        layer.fillColor = nil
        layer.lineWidth = 2.0
        return layer
    }()

    private let maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        leftArrowView = ArrowView()
        rightArrowView = ArrowView()
        rightArrowView.transform = CGAffineTransform(scaleX: -1, y: 1)

        super.init(frame: frame)

        isUserInteractionEnabled = true
        clipsToBounds = true

        addSubview(leftArrowView)
        addSubview(rightArrowView)
        layer.addSublayer(borderLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let arrowWidth: CGFloat = 12

        leftArrowView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: arrowWidth,
            height: bounds.height
        )

        rightArrowView.frame = CGRect(
            x: bounds.width - arrowWidth,
            y: 0.0,
            width: arrowWidth,
            height: bounds.height
        )

        borderLayer.frame = bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: leftArrowView.backgroundWidth, y: borderLayer.lineWidth / 2))
        path.addLine(to: CGPoint(x: bounds.width - rightArrowView.backgroundWidth, y: borderLayer.lineWidth / 2))
        let bottomLineY = bounds.height - borderLayer.lineWidth / 2
        path.move(to: CGPoint(x: leftArrowView.backgroundWidth, y: bottomLineY))
        path.addLine(to: CGPoint(x: bounds.width - rightArrowView.backgroundWidth, y: bottomLineY))
        borderLayer.path = path.cgPath

        maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 8).cgPath
        layer.mask = maskLayer
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        return bounds.inset(by: hitInsets).contains(point)
    }
}
