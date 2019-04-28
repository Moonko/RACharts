import UIKit

let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, d MMM yyyy"
    dateFormatter.locale = .autoupdatingCurrent
    return dateFormatter
}()

private let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

private let labelsSpacing: CGFloat = 2

private let dateLabelWidth: CGFloat = 20

class ChartDetailsView: UIVisualEffectView {

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColorPalette = .dateColor
        label.numberOfLines = 2
        return label
    }()

    private let percentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .right
        label.textColorPalette = .dateColor
        return label
    }()

    private let namesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColorPalette = .dateColor
        return label
    }()

    private let valuesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()

    private let allLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .right
        label.textColorPalette = .dateColor
        return label
    }()

    private let maskLayer = CAShapeLayer()

    private let showsPercentage: Bool
    private let showsAll: Bool

    private var valuesCount: Int = 0

    init(
        showsPercentage: Bool,
        showsAll: Bool
    ) {
        self.showsPercentage = showsPercentage
        self.showsAll = showsAll

        super.init(effect: nil)

        effectPalette = .effect

        contentView.addSubview(dateLabel)
        if (showsPercentage) {
            contentView.addSubview(percentsLabel)
        }
        contentView.addSubview(namesLabel)
        contentView.addSubview(valuesLabel)
        if (showsAll) {
            contentView.addSubview(allLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValues(
        _ values: [ChannelValue],
        coloredIn colors: [UIColor],
        namedAs names: [String],
        timestamp: Timestamp
    ) {
        valuesCount = values.count + (showsAll && values.count != 1 ? 1 : 0)

        dateLabel.text = dateFormatter.string(from: timestamp)

        percentsLabel.numberOfLines = valuesCount
        namesLabel.numberOfLines = valuesCount
        valuesLabel.numberOfLines = valuesCount

        let valueText = NSMutableAttributedString()
        values.enumerated().forEach {
            let mappedValue = Int(round($0.element))
            valueText.append(NSAttributedString(
                string: ($0.offset == valuesCount - 1) ? "\(mappedValue)" : "\(mappedValue)\n",
                attributes:[
                    .foregroundColor: colors[$0.offset]
                ])
            )
        }
        if (showsAll && valuesCount != 1) {
            let sum = Int(values.reduce(0, +))
            allLabel.text = "\(sum)"
        }
        valuesLabel.attributedText = valueText

        if (showsPercentage) {
            let percentText = NSMutableAttributedString()
            let sum = values.reduce(0, +)
            values
                .map { Int(round(($0 / sum) * 100)) }
                .enumerated()
                .forEach {
                    percentText.append(NSAttributedString(
                        string: ($0.offset == valuesCount - 1) ? "\($0.element)%" : "\($0.element)%\n"
                        )
                    )
                }
            percentsLabel.attributedText = percentText
        }

        let nameText = NSMutableAttributedString()
        names.enumerated().forEach {
            nameText.append(NSAttributedString(
                string: ($0.offset == valuesCount - 1) ? "\($0.element)" : "\($0.element)\n"
                )
            )
        }
        if (showsAll && valuesCount != 1) {
            nameText.append(NSAttributedString(string: "All"))
        }
        namesLabel.attributedText = nameText

        namesLabel.textAlignment = showsPercentage ? .right : .left

        sizeToFit()
        layoutSubviews()
    }

    override func sizeToFit() {
        let width: CGFloat = 140
        let dateLabelHeight: CGFloat = 20
        let valueLabelsHeight = CGFloat(valuesCount) * 12.0
        let percentLabelWidth: CGFloat = 28
        let namesLabelWidth: CGFloat = 50
        let valuesLabelWidth: CGFloat = 60

        dateLabel.frame.size = CGSize(
            width: width - 10 - edgeInsets.left - edgeInsets.right,
            height: dateLabelHeight
        )
        percentsLabel.frame.size = CGSize(width: percentLabelWidth, height: valueLabelsHeight)
        namesLabel.frame.size = CGSize(width: namesLabelWidth, height: valueLabelsHeight)
        valuesLabel.frame.size = CGSize(width: valuesLabelWidth, height: valueLabelsHeight)
        if (showsAll) {
            allLabel.frame.size = CGSize(width: valuesLabelWidth, height: 12.0)
        }

        frame.size = CGSize(
            width: width,
            height: dateLabelHeight + valueLabelsHeight + edgeInsets.top + edgeInsets.bottom
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dateLabel.frame.origin = CGPoint(
            x: edgeInsets.left,
            y: edgeInsets.top
        )

        percentsLabel.frame.origin = CGPoint(
            x: edgeInsets.left,
            y: dateLabel.frame.maxY
        )

        namesLabel.frame.origin = CGPoint(
            x: showsPercentage ? percentsLabel.frame.maxX : edgeInsets.left,
            y: dateLabel.frame.maxY
        )

        valuesLabel.frame.origin = CGPoint(
            x: bounds.width - edgeInsets.right - valuesLabel.frame.size.width,
            y: dateLabel.frame.maxY
        )

        if (showsAll) {
            allLabel.frame.origin = CGPoint(
                x: bounds.width - edgeInsets.right - valuesLabel.frame.size.width,
                y: valuesLabel.frame.maxY - 12.0
            )
        }

        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
        layer.mask = maskLayer
    }
}
