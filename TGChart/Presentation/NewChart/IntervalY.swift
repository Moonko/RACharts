import CoreGraphics

struct Interval<Value> {

    let min: Value
    let max: Value
}

struct IntervalY: Animatable {

    var min: CGFloat
    var max: CGFloat

    var diff: CGFloat {
        return max - min
    }
}

func + (lhs: IntervalY, rhs: IntervalY) -> IntervalY {
    return IntervalY(min: lhs.min + rhs.min, max: lhs.max + rhs.max)
}

func - (lhs: IntervalY, rhs: IntervalY) -> IntervalY {
    return IntervalY(min: lhs.min - rhs.min, max: lhs.max - rhs.max)
}

func * (lhs: IntervalY, progress: Double) -> IntervalY {
    return IntervalY(min: lhs.min * progress, max: lhs.max * progress)
}

func == (lhs: IntervalY, rhs: IntervalY) -> Bool {
    return (lhs.min == rhs.min && lhs.max == rhs.max)
}

func != (lhs: IntervalY, rhs: IntervalY) -> Bool {
    return !(lhs == rhs)
}
