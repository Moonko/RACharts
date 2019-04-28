import Foundation
import CoreGraphics

final class SumYCalculator: YCalculator {

    var ysCount: Int {
        return 1
    }

    private var curSums = [ChannelValue]()
    private var curDisabledIndexes = IndexSet()

    func calculateYIntervals(
        for channels: [Channel],
        disabledIndexes: IndexSet,
        leftIndex: Int,
        rightIndex: Int
    ) -> [IntervalY] {
        var maxValue: CGFloat = 0

        if disabledIndexes != curDisabledIndexes || curSums.isEmpty {
            curDisabledIndexes = disabledIndexes

            let enabledChannels = channels.enumerated()
                .filter { return !disabledIndexes.contains($0.offset) }
                .map { $0.element }

            curSums = (0 ..< enabledChannels.first!.values.count).map { valueIndex in
                var localSum: CGFloat = 0
                (0 ..< enabledChannels.count).forEach { channelIndex in
                    localSum += enabledChannels[channelIndex].values[valueIndex]
                }
                return localSum
            }
        }

        curSums[leftIndex ..< rightIndex].forEach { sum in
            if sum > maxValue {
                maxValue = sum
            }
        }

        return [IntervalY(min: 0, max: maxValue)]
    }
}
