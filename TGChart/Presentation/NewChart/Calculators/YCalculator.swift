import Foundation

protocol YCalculator: class {

    var ysCount: Int { get }

    func calculateYIntervals(
        for channels: [Channel],
        disabledIndexes: IndexSet,
        leftIndex: Int,
        rightIndex: Int
    ) -> [IntervalY]
}
