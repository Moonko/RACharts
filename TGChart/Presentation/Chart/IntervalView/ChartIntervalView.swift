import UIKit

let minIntervalDiff: CGFloat = 0.2

class ChartIntervalView: UIView {

    var onIntervalChange: ((Interval<CGFloat>) -> Void)?

    var interval = Interval<CGFloat>(min: 0, max: 1) {
        didSet {
            if #available(iOS 10, *) {
                if interval.min == 0 {
                    if !minReached {
                        minReached = true
                        let generator = UISelectionFeedbackGenerator()
                        generator.prepare()
                        generator.selectionChanged()
                    }
                } else {
                    minReached = false
                }
                if interval.max == 1 {
                    if !maxReached {
                        maxReached = true
                        let generator = UISelectionFeedbackGenerator()
                        generator.prepare()
                        generator.selectionChanged()
                    }
                } else {
                    maxReached = false
                }
            }

            layoutControlView()
            onIntervalChange?(interval)
        }
    }

    let chartView: ChartView

    private let controlView = ControlView()

    private let unselectedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColorPalette = .deselectedColor
        layer.strokeColor = nil
        return layer
    }()

    private let maskLayer = CAShapeLayer()

    private var controlPanRecognizer: UIPanGestureRecognizer!
    private var leftArrowPanRecognizer: UIPanGestureRecognizer!
    private var rightArrowPanRecognizer: UIPanGestureRecognizer!

    init(chartView: ChartView) {
        self.chartView = chartView

        super.init(frame: .zero)

        isUserInteractionEnabled = true
        clipsToBounds = true
        unselectedLayer.masksToBounds = true

        addSubview(chartView)
        chartView.layer.addSublayer(unselectedLayer)
        addSubview(controlView)

        controlPanRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleControlPan(recognizer:))
        )
        controlPanRecognizer.delegate = self
        controlView.addGestureRecognizer(controlPanRecognizer)

        leftArrowPanRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleLeftArrowPan(recognizer:))
        )
        leftArrowPanRecognizer.delegate = self
        controlView.leftArrowView.addGestureRecognizer(leftArrowPanRecognizer)

        rightArrowPanRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleRightArrowPan(recognizer:))
        )
        rightArrowPanRecognizer.delegate = self
        controlView.rightArrowView.addGestureRecognizer(rightArrowPanRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var minReached = true
    private var maxReached = true

    @objc
    private func handleControlPan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.translation(in: self).x
        let relativeOffset = location == 0 ? 0 : location / bounds.width
        recognizer.setTranslation(.zero, in: self)

        var diffToAdd: CGFloat = relativeOffset

        let newMin = interval.min + diffToAdd
        diffToAdd = newMin < 0 ? -interval.min : diffToAdd

        let newMax = interval.max + diffToAdd
        diffToAdd = newMax > 1 ? 1 - interval.max : diffToAdd

        interval = Interval(
            min: max(interval.min + diffToAdd, 0),
            max: min(interval.max + diffToAdd, 1)
        )
    }

    @objc
    private func handleLeftArrowPan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.translation(in: self).x
        let relativeOffset = location == 0 ? 0 : location / bounds.width
        recognizer.setTranslation(.zero, in: self)

        interval = Interval(
            min: constrainedMin(byAdding: relativeOffset),
            max: interval.max
        )
    }

    func constrainedMin(byAdding delta: CGFloat) -> CGFloat {
        return min(max(interval.min + delta, 0), interval.max - minIntervalDiff)
    }

    func constrainedMax(byAdding delta: CGFloat) -> CGFloat {
        return max(min(interval.max + delta, 1), interval.min + minIntervalDiff)
    }

    @objc
    private func handleRightArrowPan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.translation(in: self).x
        let relativeOffset = location == 0 ? 0 : location / bounds.width
        recognizer.setTranslation(.zero, in: self)

        interval = Interval(
            min: interval.min,
            max: constrainedMax(byAdding: relativeOffset)
        )
    }

    private func layoutControlView() {
        controlView.frame = CGRect(
            x: bounds.width * interval.min,
            y: 0.0,
            width: bounds.width * (interval.max - interval.min),
            height: bounds.height
        )

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        if controlView.frame.minX > 0 {
            path.addLine(to: CGPoint(x: controlView.frame.minX + 8, y: 0))
            path.addLine(to: CGPoint(x: controlView.frame.minX + 8, y: unselectedLayer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: unselectedLayer.bounds.height))
            path.close()
        }
        path.move(to: CGPoint(x: controlView.frame.maxX - 8, y: 0))
        if controlView.frame.maxX < bounds.maxX {
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: unselectedLayer.bounds.height))
            path.addLine(to: CGPoint(x: controlView.frame.maxX - 8, y: unselectedLayer.bounds.height))
            path.close()
        }
        unselectedLayer.path = path.cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        chartView.frame = CGRect(
            x: 0.0,
            y: 2,
            width: bounds.width,
            height: bounds.height - 2 * 2
        )
        unselectedLayer.frame = chartView.bounds

        maskLayer.path = UIBezierPath(roundedRect: chartView.bounds, cornerRadius: 8).cgPath
        chartView.layer.mask = maskLayer

        layoutControlView()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        return bounds.inset(by: hitInsets).contains(point)
    }
}

extension ChartIntervalView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === controlPanRecognizer
            || gestureRecognizer === leftArrowPanRecognizer
            || gestureRecognizer === rightArrowPanRecognizer
            else { return true }

        let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
    }
}
