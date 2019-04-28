import Foundation
import CoreGraphics

final class CommonYCalculator: YCalculator {

    var ysCount: Int {
        return 1
    }

    func calculateYIntervals(
        for channels: [Channel],
        disabledIndexes: IndexSet,
        leftIndex: Int,
        rightIndex: Int
        ) -> [IntervalY] {
        var minValue: CGFloat = .greatestFiniteMagnitude
        var maxValue: CGFloat = 0

        channels.enumerated()
            .filter { return !disabledIndexes.contains($0.offset) }
            .forEach {
                $0.element.values[(leftIndex) ... rightIndex].forEach { value in
                    if value < minValue {
                        minValue = value
                    } else if value > maxValue {
                        maxValue = value
                    }
                }
        }

        var newInterval: IntervalY
        if minValue < .greatestFiniteMagnitude && maxValue > .leastNormalMagnitude {
            newInterval = IntervalY(min: minValue, max: maxValue)
        } else {
            newInterval = IntervalY(min: 0, max: 0)
        }

        return [newInterval]
    }
}
