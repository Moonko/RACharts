import UIKit

let dataSelectorCellHeight: CGFloat = 44

private let arrowSize = CGSize(width: 12, height: 12)
private let dataContentInset: CGFloat = 10
private let arrowOriginY = dataSelectorCellHeight / 2 - arrowSize.height / 2
private let backgroundInsetY: CGFloat = 7
private let backgroundHeight = dataSelectorCellHeight - backgroundInsetY * 2
private let halfHeight = dataSelectorCellHeight / 2
private let selectedLabelOrigin = dataContentInset + arrowSize.width + dataContentInset

class DataSelectorCollectionViewCell: UICollectionViewCell {

    var dataSelected = false

    static let manequeenCell = DataSelectorCollectionViewCell(frame: .zero)

    static func width(for text: String) -> CGFloat {
        manequeenCell.textLayer.string = text
        let textSize = manequeenCell.textLayer.preferredFrameSize()
        return selectedLabelOrigin + textSize.width + dataContentInset
    }

    private let textLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.fontSize = 14
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()

    private let checkmarkLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.fillColor = nil
        layer.lineWidth = 3 / UIScreen.main.scale
        return layer
    }()

    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3 / UIScreen.main.scale
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(checkmarkLayer)
        contentView.layer.addSublayer(textLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var color: UIColor?

    func setText(_ text: String, color: UIColor) {
        textLayer.string = text
        self.color = color
        backgroundLayer.strokeColor = color.cgColor
    }

    private func layoutTextLayer() {
        let textSize = textLayer.preferredFrameSize()
        textLayer.frame = CGRect(
            origin: CGPoint(
                x: dataSelected ? selectedLabelOrigin : bounds.width / 2 - textSize.width / 2,
                y: halfHeight - textSize.height / 2
            ),
            size: textSize
        )
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        let willBeUpdated = selected != dataSelected

        self.dataSelected = selected

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setDisableActions(!animated || !willBeUpdated)
        self.checkmarkLayer.strokeEnd = selected ? 1.0 : 0.0
        self.textLayer.foregroundColor = selected ? UIColor.white.cgColor : self.color?.cgColor
        self.backgroundLayer.fillColor = selected ? self.color?.cgColor : nil
        self.layoutTextLayer()
        CATransaction.commit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        checkmarkLayer.frame = CGRect(
            origin: CGPoint(
                x: dataContentInset,
                y: arrowOriginY
            ),
            size: arrowSize
        )
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: 0, y: arrowSize.height * 0.6))
        checkmarkPath.addLine(to: CGPoint(x: arrowSize.width * 0.3, y: arrowSize.height - checkmarkPath.lineWidth))
        checkmarkPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.2))
        checkmarkLayer.path = checkmarkPath.cgPath

        backgroundLayer.frame = CGRect(
            x: 0,
            y: backgroundInsetY,
            width: contentView.bounds.width,
            height: backgroundHeight
        )
        backgroundLayer.path = UIBezierPath(
            roundedRect: backgroundLayer.bounds,
            cornerRadius: 6
        ).cgPath

        layoutTextLayer()
    }
}
