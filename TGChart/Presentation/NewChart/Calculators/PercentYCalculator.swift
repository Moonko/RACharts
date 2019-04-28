import Foundation
import CoreGraphics

final class PercentYCalculator: YCalculator {

    var ysCount: Int {
        return 1
    }

    func calculateYIntervals(
        for channels: [Channel],
        disabledIndexes: IndexSet,
        leftIndex: Int,
        rightIndex: Int
    ) -> [IntervalY] {
        return [IntervalY(min: 0, max: 100)]
    }
}
