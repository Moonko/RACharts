import UIKit

final class FloatingLegendYRenderer: UIView, LegendYRenderer {

    var needsRendering: Bool = false

    var viewport: Viewport!

    private var ysInPoints = [CGFloat]()

    private let valuesCount: Int
    private let showsTopValue: Bool

    private var fromValues = [[ChannelValue]]()
    private var toValues = [[ChannelValue]]()

    private var fromValuesToYs = [[CGFloat]]()
    private var toValuesFromYs = [[CGFloat]]()

    private var fadeAnimator: AlphaAnimator!
    private var animationProgress: CGFloat = 0
    private var indexesToAnimate = [[Int]]()

    var colors = [UIColor]()

    private var toLineViews = [UIView]()
    private var fromLineViews = [UIView]()

    init(valuesCount: Int, showsTopValue: Bool) {
        self.valuesCount = valuesCount
        self.showsTopValue = showsTopValue

        super.init(frame: .zero)

        let fromValue = showsTopValue ? 0 : 1

        toLineViews = (fromValue ..< valuesCount).map { _ in
            let view = UIView()
            view.backgroundPalette = .chartLine
            addSubview(view)
            return view
        }

        fromLineViews = (fromValue ..< valuesCount).map { _ in
            let view = UIView()
            view.backgroundPalette = .chartLine
            addSubview(view)
            return view
        }

        fadeAnimator = AlphaAnimator() {
            self.animationProgress = $0
            self.needsRendering = true
        }

        backgroundColor = .clear

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reactOnThemeChange),
            name: .themeUpdateNotificationName,
            object: nil
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func reactOnThemeChange() {
        needsRendering = true
    }

    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 1.0

        let valueColorsToChoose: [UIColor] = {
            if (viewport.ysCount > 1) {
                return colors
            } else {
                return [
                    Palette.yColor.typedCurrent(),
                    Palette.yColor.typedCurrent()
                ]
            }
        }()

        let secondTextParagraphStyle = NSMutableParagraphStyle()
        secondTextParagraphStyle.alignment = .right

        toValues.first?.enumerated().forEach {
            let value = $0.element
            let valueIndex = $0.offset

            let progress = indexesToAnimate.first?.contains($0.offset) == true ? animationProgress : 1

            var positionY: CGFloat
            let toPoint = ysInPoints[valueIndex]
            if let fromPoint = toValuesFromYs.first?[valueIndex] {
                positionY = fromPoint + (toPoint - fromPoint) * progress
            } else {
                positionY = toPoint
            }

            let colorAlpha = valueColorsToChoose.first!.cgColor.alpha * progress
            if (colorAlpha > 0.1) {
                NSAttributedString(
                    string: "\(Int(value).roundedWithAbbreviations)",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: valueColorsToChoose.first!.withAlphaComponent(colorAlpha),
                        .paragraphStyle: secondTextParagraphStyle
                    ]
                    ).draw(at: CGPoint(x: 0, y: positionY - 14))
            }

            // Draw line

            let view = toLineViews[valueIndex]
            view.alpha = progress
            view.frame.origin.y = positionY - lineWidth
        }

        fromValues.first?.enumerated().forEach {
            let value = $0.element
            let valueIndex = $0.offset

            let progress = indexesToAnimate.first?.contains($0.offset) == true ? animationProgress : 1

            var positionY: CGFloat
            let fromPoint = ysInPoints[valueIndex]
            if let toPoint = fromValuesToYs.first?[valueIndex] {
                positionY = fromPoint + (toPoint - fromPoint) * progress
            } else {
                positionY = fromPoint
            }

            let colorAlpha = valueColorsToChoose.first!.cgColor.alpha * (1 - progress)
            if (colorAlpha > 0.1) {
                NSAttributedString(
                    string: "\(Int(value).roundedWithAbbreviations)",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: valueColorsToChoose.first!.withAlphaComponent(colorAlpha)
                    ]
                ).draw(at: CGPoint(x: 0, y: positionY - 14))
            }

            // Draw line

            let view = fromLineViews[valueIndex]
            view.alpha = 1 - progress
            view.frame.origin.y = $0.element - lineWidth
        }

        if (fromValues.count > 1) {
            fromValues.last?.enumerated().forEach {
                let value = $0.element
                let valueIndex = $0.offset

                let progress = indexesToAnimate.last?.contains($0.offset) == true ? animationProgress : 1

                var positionY: CGFloat
                let fromPoint = ysInPoints[valueIndex]
                if let toPoint = fromValuesToYs.last?[valueIndex] {
                    positionY = fromPoint + (toPoint - fromPoint) * progress
                } else {
                    positionY = fromPoint
                }

                let colorAlpha = valueColorsToChoose.last!.cgColor.alpha * (1 - progress)
                if (colorAlpha > 0.1) {
                    NSAttributedString(
                        string: "\(Int(value).roundedWithAbbreviations)",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 10),
                            .foregroundColor: valueColorsToChoose.last!.withAlphaComponent(colorAlpha),
                            .paragraphStyle: secondTextParagraphStyle
                        ]
                        ).draw(in: CGRect(
                            x: bounds.width - 100,
                            y: positionY - 14,
                            width: 100,
                            height: 12)
                    )
                }
            }

            toValues.last?.enumerated().forEach {
                let value = $0.element
                let valueIndex = $0.offset

                let progress = indexesToAnimate.last?.contains($0.offset) == true ? animationProgress : 1

                var positionY: CGFloat
                let toPoint = ysInPoints[valueIndex]
                if let fromPoint = toValuesFromYs.last?[valueIndex] {
                    positionY = fromPoint + (toPoint - fromPoint) * progress
                } else {
                    positionY = toPoint
                }

                let colorAlpha = valueColorsToChoose.last!.cgColor.alpha * progress
                if (colorAlpha > 0.1) {
                    NSAttributedString(
                        string: "\(Int(value).roundedWithAbbreviations)",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 10),
                            .foregroundColor: valueColorsToChoose.last!.withAlphaComponent(colorAlpha),
                            .paragraphStyle: secondTextParagraphStyle
                        ]
                        ).draw(in: CGRect(
                            x: bounds.width - 100,
                            y: positionY - 14,
                            width: 100,
                            height: 12)
                    )
                }
            }
        }
    }

    func chartWillTransition(to toIntervals: [IntervalY]) {
        let toSpacingYs = viewport.spacingYs(for: toIntervals.enumerated().map {
            viewport.defaultDiffYs[$0.offset] / $0.element.diff
        })
        let newValues = (0 ..< toIntervals.count).map { yIndex in
            ysInPoints.map { toIntervals[yIndex].max - ChannelValue(round(($0 - viewport.insets.top) / toSpacingYs[yIndex])) }
        }

        if (fromValues.isEmpty) {
            fromValues = newValues
        }

        guard fadeAnimator.state != .inProgress && !toValues.isEmpty else {
            toValues = newValues
            return
        }

        fromValues = toValues
        toValues = newValues

        indexesToAnimate = (0 ..< toIntervals.count).map { yIndex in
            return (0 ..< fromValues[yIndex].count).filter { valueIndex in
                return fromValues[yIndex][valueIndex] != toValues[yIndex][valueIndex]
            }
        }

        fadeAnimator.animate(0, toValue: 1)

        toValuesFromYs = toValues.enumerated().map { iter -> [CGFloat] in
            let yIndex = iter.offset
            let values = iter.element
            return values.map { value -> CGFloat in
                return viewport.y(for: value, at: yIndex)
            }
        }

        fromValuesToYs = fromValues.enumerated().map { iter -> [CGFloat] in
            let yIndex = iter.offset
            let values = iter.element

            return values.map { value -> CGFloat in
                return viewport.insets.top + (toIntervals[yIndex].max - value) * toSpacingYs[yIndex]
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let step = (viewport.size.height - viewport.insets.top) / CGFloat(valuesCount - 1)
        let startIndex = showsTopValue ? 0 : 1
        ysInPoints = (startIndex ..< valuesCount).map { index in
            return viewport.insets.top + step * CGFloat(index)
        }

        fromLineViews.forEach {
            $0.frame = CGRect(
                x: 0,
                y: 0,
                width: bounds.width,
                height: 1
            )
        }

        toLineViews.forEach {
            $0.frame = CGRect(
                x: 0,
                y: 0,
                width: bounds.width,
                height: 1
            )
        }

        needsRendering = true
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

extension Int {

    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(Int(number))"
        }
    }
}

