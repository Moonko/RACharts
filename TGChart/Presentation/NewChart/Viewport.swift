import UIKit

final class Viewport {

    private(set) var relOffsetLeft: CGFloat = 0
    private(set) var relOffsetRight: CGFloat = 0
    private(set) var relOffsetTop: CGFloat = 0
    private(set) var relOffsetBottom: CGFloat = 0

    // MARK: Size

    var size = CGSize.zero {
        didSet {
            relOffsetLeft = insets.left / size.width
            relOffsetRight = insets.right / size.width
            relOffsetTop = (insets.top / (size.height)) * 2.0
            relOffsetBottom = (insets.bottom / (size.height)) * 2.0
        }
    }

    // MARK: Interval

    var intervalX = Interval<CGFloat>(min: 0, max: 1) {
        didSet {
            updateScaleX()
        }
    }

    var intervalYs: [IntervalY] {
        didSet {
            updateScaleYs()
        }
    }

    var defaultDiffYs: [ChannelValue]
    var defaultMaxYs: [ChannelValue]

    // MARK: Scale

    var scaleX: CGFloat = 1 {
        didSet {
            spacingX = defaultSpacingX * scaleX
            lastLeftIndex = closestIndex(to: translateLeft)
            lastRightIndex = closestIndex(to: translateLeft - 1)
            // update timestamps
        }
    }

    var scaleYs: [CGFloat] {
        didSet {
            spacingYs = (0 ..< ysCount).map { index in
                defaultSpacingYs[index] * scaleYs[index]
            }
        }
    }

    // MARK: Spacing

    var spacingX: CGFloat = 0
    var spacingYs = [CGFloat]()

    var defaultSpacingX: CGFloat = 0
    var defaultSpacingYs = [CGFloat]()

    // MARK: Translation in [0..1]

    var translateLeft: CGFloat = 0
    var translateRight: CGFloat = 0

    // MARK: Timestamps

    private var timestampsCount = 0

    // MARK: Last calculations

    private(set) var lastLeftIndex = 0
    private(set) var lastRightIndex = 0

    var insets: UIEdgeInsets

    let ysCount: Int

    init(ysCount: Int, insets: UIEdgeInsets) {
        self.ysCount = ysCount
        self.intervalYs = (0 ..< ysCount).map { _ in return IntervalY(min: 0, max: 0) }
        self.defaultDiffYs = (0 ..< ysCount).map { _ in return 0 }
        self.defaultMaxYs = (0 ..< ysCount).map { _ in return 0 }
        self.scaleYs = (0 ..< ysCount).map { _ in return 1 }
        self.defaultSpacingYs = (0 ..< ysCount).map { _ in return 0 }

        self.insets = insets
    }

    private func updateScaleX() {
        let newScaleX = (1 - relOffsetLeft - relOffsetRight) / (intervalX.max - intervalX.min)
        translateLeft = -newScaleX * intervalX.min + relOffsetLeft
        translateRight = newScaleX * (1 - intervalX.max) - relOffsetRight
        scaleX = newScaleX
    }

    private func updateScaleYs() {
        scaleYs = (0 ..< ysCount).map { index in
            defaultDiffYs[index] / intervalYs[index].diff
        }
    }

    func updateDefaultXScales(timestampsCount: Int) {
        self.timestampsCount = timestampsCount

        defaultSpacingX = size.width / CGFloat(timestampsCount - 1)
        updateScaleX()
    }

    func spacingYs(for scales: [CGFloat]) -> [CGFloat] {
        return (0 ..< ysCount).map { index in
            defaultSpacingYs[index] * scales[index]
        }
    }

    func updateDefaultYScales(with defaultIntervalsY: [IntervalY]) {
        (0 ..< ysCount).forEach { index in
            let curInterval = defaultIntervalsY[index]
            defaultDiffYs[index] = curInterval.diff
            defaultMaxYs[index] = curInterval.max
            defaultSpacingYs[index] = (size.height - insets.top - insets.bottom) / CGFloat(defaultDiffYs[index])
        }
        intervalYs = defaultIntervalsY
    }

    func closestIndex(to translateX: CGFloat) -> Int {
        return max(min(Int(round(-translateX * size.width / spacingX)), timestampsCount - 1), 0)
    }

    func y(for value: ChannelValue, at index: Int) -> CGFloat {
        return insets.top + (intervalYs[index].max - value) * spacingYs[index]
    }
}
