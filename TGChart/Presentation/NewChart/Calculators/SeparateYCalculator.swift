import CoreGraphics
import Foundation

final class SeparateYCalculator: YCalculator {

    var ysCount: Int {
        return 2
    }

    func calculateYIntervals(
        for channels: [Channel],
        disabledIndexes: IndexSet,
        leftIndex: Int,
        rightIndex: Int
    ) -> [IntervalY] {
        return (0 ..< ysCount).map { index in
            var minValue: CGFloat = .greatestFiniteMagnitude
            var maxValue: CGFloat = 0

            if index > channels.count - 1 {
                return IntervalY(min: 0, max: 0)
            }

            let channel = channels[index]
            channel.values[(leftIndex) ... rightIndex].forEach { value in
                if value < minValue {
                    minValue = value
                } else if value > maxValue {
                    maxValue = value
                }
            }

            var newInterval: IntervalY
            if minValue < .greatestFiniteMagnitude && maxValue > .leastNormalMagnitude {
                newInterval = IntervalY(min: minValue, max: maxValue)
            } else {
                newInterval = IntervalY(min: 0, max: 0)
            }
            return newInterval
        }
    }
}
