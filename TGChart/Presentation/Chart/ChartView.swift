import UIKit

private let legendXHeight: CGFloat = 20
private let detailsViewOffset: CGFloat = 12

final class ChartView: UIView {

    // MARK: Properties

    private var lastUpdatedIntervalYs = [IntervalY]()

    // Viewport
    private var insets: UIEdgeInsets

    private let viewport: Viewport

    var intervalX: Interval<CGFloat> {
        get {
            return viewport.intervalX
        }
        set {
            viewport.intervalX = newValue
            updateXRenderers()
            updateIntervalY()
            chartRenderer.needsRendering = true
        }
    }

    var intervalYs: [IntervalY] {
        get {
            return viewport.intervalYs
        }
        set {
            viewport.intervalYs = newValue
            chartRenderer.needsRendering = true
        }
    }

    // Helpers
    private var yCalculator: YCalculator
    private var chartRenderer: ChartRenderer
    private var legendXRenderer: LegendXRenderer?
    private var legendYRenderer: LegendYRenderer?

    // Dates
    private var leftDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColorPalette = .tintColor
        label.textAlignment = .right
        return label
    }()
    private var dashLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColorPalette = .tintColor
        label.textAlignment = .center
        return label
    }()
    private var rightDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColorPalette = .tintColor
        label.textAlignment = .left
        return label
    }()

    // Rendering
    private var displayLink: CADisplayLink?

    // Last values
    private var lastBounds: CGSize = .zero

    // Data
    private var channels = [Channel]()
    private var timestamps = [Timestamp]()

    // Data updates
    private var values = [[ChannelValue]]()
    private var colors = [UIColor]()
    private var visibilities = [GLfloat]()
    private var disabledChannelIndexes = IndexSet()

    private var isStacked: Bool = false
    private var isPercent: Bool = false
    private let detailsEnabled: Bool

    private var needsUpdateChartY = false

    private var panGestureRecognizer: UIPanGestureRecognizer!

    // Animations
    private var alphaAnimators = [AlphaAnimator]()
    private var intervalYAnimators: [IntervalYAnimator]!

    // Details
    private var selectedIndex: Int?
    private var lastX: CGFloat = 0
    private var detailsPointerView: UIView!
    private var detailsView: ChartDetailsView!
    private var detailsMaskView: UIView!
    private var detailsMaskLayer: CAShapeLayer!
    private var detailsPointsLayers = [Int: CAShapeLayer]()

    // MARK: Init

    init(
        insets: UIEdgeInsets,
        yCalculator: YCalculator,
        chartRenderer: ChartRenderer,
        legendXRenderer: LegendXRenderer? = nil,
        legendYRenderer: LegendYRenderer? = nil,
        detailsEnabled: Bool
    ) {
        self.insets = insets
        if (chartRenderer.startsFromZero) {
            self.insets.bottom = 0
        }

        self.detailsEnabled = detailsEnabled
        self.viewport = Viewport(
            ysCount: yCalculator.ysCount,
            insets: self.insets
        )
        self.yCalculator = yCalculator
        self.chartRenderer = chartRenderer

        self.legendYRenderer = legendYRenderer
        self.legendYRenderer?.viewport = viewport

        self.legendXRenderer = legendXRenderer
        self.legendXRenderer?.viewport = viewport

        self.chartRenderer.viewport = viewport

        super.init(frame: .zero)

        intervalYAnimators = (0 ..< yCalculator.ysCount).map { index in
            return IntervalYAnimator() { [weak self] newIntervalY in
                self?.intervalYs[index] = newIntervalY
            }
        }

        addSubview(chartRenderer)
        if let legendXRenderer = legendXRenderer {
            addSubview(legendXRenderer)
        }
        if let legendYRenderer = legendYRenderer {
            addSubview(legendYRenderer)
        }
        if detailsEnabled {
            addSubview(leftDateLabel)
            addSubview(dashLabel)
            addSubview(rightDateLabel)
        }

        clipsToBounds = true

        if (detailsEnabled) {
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(handlePan))
            panGestureRecognizer.delegate = self
            chartRenderer.addGestureRecognizer(panGestureRecognizer)
        }

        startRenderingLoop()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDataSet(_ dataSet: DataSet) {
        reset()

        timestamps = dataSet.timestamps
        isStacked = dataSet.stacked
        isPercent = dataSet.percentage

        dataSet.channels.enumerated().forEach {
            let channel = $0.element
            let index = $0.offset

            channels.append(channel)
            colors.append(channel.color)
            visibilities.append(1)
            alphaAnimators.append(AlphaAnimator() { [weak self] newAlpha in
                guard let strongSelf = self else { return }

                if (strongSelf.isStacked) {
                    strongSelf.visibilities[index] = GLfloat(newAlpha)
                    strongSelf.needsUpdateChartY = true
                } else {
                    strongSelf.colors[index] = strongSelf.channels[index].color.withAlphaComponent(newAlpha)
                    if (strongSelf.viewport.ysCount > 1) {
                        strongSelf.legendYRenderer?.colors = strongSelf.colors
                        strongSelf.legendYRenderer?.needsRendering = true
                    }
                }

                strongSelf.chartRenderer.needsRendering = true
            })
        }

        legendYRenderer?.colors = channels.map { $0.color }
        legendXRenderer?.setTimestamps(dataSet.timestamps)

        guard bounds.size != .zero else { return }

        updateDefaults()
    }

    private func updateChartRenderer() {
        let relScaleX = viewport.scaleX

        let relTranslateX = viewport.translateLeft + viewport.translateRight

        let matrices = (0 ..< viewport.ysCount).map { index -> [CGFloat] in
            let relScaleY = viewport.scaleYs[index]

            let oldLocation = (1 - viewport.relOffsetTop - (CGFloat((viewport.defaultMaxYs[index] - intervalYs[index].max)) / CGFloat(viewport.defaultDiffYs[index])) * (2 - viewport.relOffsetTop - viewport.relOffsetBottom))
            let newLocation = oldLocation * viewport.scaleYs[index]
            let relTranslateY = (1 - viewport.relOffsetTop) - newLocation

            return [
                relScaleX, 0, 0, 0,
                0, relScaleY, 0, 0,
                0, 0, 1, 0,
                relTranslateX, relTranslateY, 0, 1
            ]
        }

        chartRenderer.update(
            with: matrices,
            colors: colors.reduce([CGFloat]()) {
                return $0 + $1.cgColor.components!
            }
        )

        chartRenderer.needsRendering = true
    }

    func enableChannels(at indexes: [Int]) {
        indexes.forEach { index in
            disabledChannelIndexes.remove(index)
            showChart(at: index)
        }

        updateIntervalY()
    }

    func disableChannels(at indexes: [Int]) {
        indexes.forEach { index in
            disabledChannelIndexes.insert(index)
            hideChart(at: index)
        }

        updateIntervalY()
    }

    func enableChannels(at indexesToEnable: [Int],
                        disableAt indexesToDisable: [Int]) {

        indexesToDisable.forEach { index in
            disabledChannelIndexes.insert(index)
            hideChart(at: index)
        }

        indexesToEnable.forEach { index in
            disabledChannelIndexes.remove(index)
            showChart(at: index)
        }

        updateIntervalY()
    }

    private func showChart(at index: Int) {
        if (isStacked) {
            alphaAnimators[index].animate(CGFloat(visibilities[index]), toValue: 1)
        } else {
            alphaAnimators[index].animate(colors[index].cgColor.alpha, toValue: 1)
        }
    }

    private func hideChart(at index: Int) {
        if (isStacked) {
            alphaAnimators[index].animate(CGFloat(visibilities[index]), toValue: 0)
        } else {
            alphaAnimators[index].animate(colors[index].cgColor.alpha, toValue: 0)
        }
    }

    private func reset() {

    }

    // MARK: Date Label

    private func updateDateLabel(from fromIndex: Int, to toIndex: Int) {
        guard detailsEnabled else { return }

        leftDateLabel.text = topDateFormatter.string(
            from: timestamps[fromIndex]
        )
        rightDateLabel.text = topDateFormatter.string(
            from: timestamps[toIndex]
        )
    }

    // MARK: Rendering

    private func startRenderingLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        if #available(iOS 10, *) {} else { displayLink?.frameInterval = 2 }
        displayLink?.add(to: .current, forMode: .common)
    }

    private func stopRenderingLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc
    private func render() {
        if (chartRenderer.needsRendering) {
            if (needsUpdateChartY) {
                needsUpdateChartY = false
                if (isPercent) {
                    updateDefaultYValues()
                }
                updateChartRendererYValues()
            }
            updateDetailsViewIfNeeded()
            updateChartRenderer()
            chartRenderer.renderIfNeeded()
        }
        legendXRenderer?.renderIfNeeded()
        legendYRenderer?.renderIfNeeded()
    }

    // MARK: Viewport

    private func updateIntervalY() {
        let newIntervals = yCalculator.calculateYIntervals(
            for: channels,
            disabledIndexes: disabledChannelIndexes,
            leftIndex: viewport.lastLeftIndex,
            rightIndex: viewport.lastRightIndex
        )

        guard lastUpdatedIntervalYs != newIntervals else { return }
        lastUpdatedIntervalYs = newIntervals

        (0 ..< viewport.ysCount).forEach { index in
            if viewport.defaultDiffYs[index] != 0 {
                intervalYAnimators[index].animate(viewport.intervalYs[index], toValue: newIntervals[index])
            }
        }
        if (viewport.defaultDiffYs[0] == 0) {
            viewport.updateDefaultYScales(with: newIntervals)
        }
        legendYRenderer?.chartWillTransition(to: newIntervals)
        legendYRenderer?.needsRendering = true
    }

    // MARK: Scaling

    // [0, 1]
    private var defaultYValues = [[GLfloat]]()

    private func updateChartRendererYValues() {
        var yValues: [[GLfloat]] = defaultYValues
        if (isStacked) {
            var prevValues = [GLfloat]()
            prevValues.reserveCapacity(timestamps.count)
            yValues = zip(defaultYValues, visibilities).map { curValues, visibility in
                if (prevValues.isEmpty) {
                    prevValues = curValues.map { 1 - (1 - $0) * visibility }
                } else {
                    prevValues = zip(curValues, prevValues).map { ($0 - 1) * visibility + $1 }
                }
                return prevValues
            }
        }
        chartRenderer.updateYValues(with: yValues)
    }

    private func updateDefaults() {
        viewport.updateDefaultXScales(timestampsCount: timestamps.count)
        updateIntervalY()

        var timestampValues = [CGFloat]()
        let step = viewport.size.width / CGFloat(timestamps.count - 1)
        var curX: CGFloat = 0
        (0 ..< timestamps.count).forEach { _ in
            timestampValues.append(curX / viewport.size.width)
            curX += step
        }

        chartRenderer.updateXValues(with: timestampValues, linesCount: channels.count)
        updateXRenderers()

        updateDefaultYValues()
        updateChartRendererYValues()

        chartRenderer.needsRendering = true
    }

    private func updateXRenderers() {
        let fromIndex = viewport.closestIndex(to: viewport.translateLeft - viewport.relOffsetLeft)
        let toIndex = viewport.closestIndex(to: viewport.translateLeft - viewport.relOffsetLeft - (1 - viewport.relOffsetRight - viewport.relOffsetLeft))

        updateDateLabel(from: fromIndex, to: toIndex)

        legendXRenderer?.update(from: fromIndex, to: toIndex)
        legendXRenderer?.needsRendering = true
    }

    private func updateDefaultYValues() {
        var sums = [GLfloat]()
        if (isPercent) {
            var prevValues = [GLfloat]()
            prevValues.reserveCapacity(timestamps.count)
            sums = zip(channels, visibilities).map { channel, visibility -> [GLfloat] in
                if (prevValues.isEmpty) {
                    prevValues = channel.values.map { GLfloat($0) * visibility }
                } else {
                    prevValues = zip(channel.values, prevValues).map { (GLfloat($0) * visibility) + $1 }
                }
                return prevValues
            }.last!
        }
        defaultYValues = channels.enumerated().map {
            let channelIndex = $0.offset
            let channel = $0.element
            let yIndex = min(channelIndex, yCalculator.ysCount - 1)

            let drawableHeight = viewport.size.height - insets.top - insets.bottom
            let insetTopPercent = insets.top / viewport.size.height
            return channel.values.enumerated().map { iter in
                let value = iter.element
                let valueIndex = iter.offset
                let valueToCalculate = isPercent ? (GLfloat(value) / sums[valueIndex]) * 100 : GLfloat(value)
                let percent = (GLfloat(viewport.defaultMaxYs[yIndex]) - valueToCalculate) / GLfloat(viewport.defaultDiffYs[yIndex])
                let insettedHeight = percent * GLfloat(drawableHeight)
                return GLfloat(insetTopPercent) + insettedHeight / GLfloat(viewport.size.height)
            }
        }
    }

    // MARK: Details

    @objc
    private func handlePan() {
        let location = panGestureRecognizer.location(in: self)
        switch panGestureRecognizer.state {
        case .began:
            if !addDetailsViewIfNeeded(location: location) {
                moveDetailsView(to: location, animated: true)
            }
        case .changed:
            moveDetailsView(to: location, animated: true)
        default:
            removeDetailsViewIfNeeded()
        }
        panGestureRecognizer.setTranslation(.zero, in: chartRenderer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard detailsEnabled else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        addDetailsViewIfNeeded(location: location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard detailsEnabled else { return }

        removeDetailsViewIfNeeded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard detailsEnabled else { return }

        removeDetailsViewIfNeeded()
    }

    private func updateDetailsViewIfNeeded() {
        guard detailsView?.superview != nil else { return }

        removeDetailsView()
        addDetailsView(to: CGPoint(x: lastX, y: 0))
    }

    private func removeDetailsViewIfNeeded() {
        guard let panGestureRecognizer = panGestureRecognizer else { return }

        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            return
        }

        removeDetailsView()
    }

    private func removeDetailsView() {
        detailsView.removeFromSuperview()
        detailsPointerView?.removeFromSuperview()
        detailsMaskView?.removeFromSuperview()
        detailsMaskLayer?.removeFromSuperlayer()
        detailsPointsLayers.values.forEach { $0.removeFromSuperlayer() }
        detailsPointsLayers.removeAll()
    }

    @discardableResult
    private func addDetailsViewIfNeeded(location: CGPoint) -> Bool {
        guard detailsPointerView?.superview == nil else { return false }

        addDetailsView(to: location)

        if #available(iOS 10, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }

        return true
    }

    private func addDetailsView(to location: CGPoint) {
        selectedIndex = nil

        detailsPointerView = UIView()
        detailsPointerView.backgroundPalette = Palette.chartLine
        chartRenderer.addSubview(detailsPointerView)

        detailsView = ChartDetailsView(
            showsPercentage: isPercent,
            showsAll: isStacked && !isPercent
        )
        addSubview(detailsView)

        switch chartRenderer.selectionType {
        case .mask:
            detailsMaskView = UIView()
            detailsMaskView.backgroundPalette = Palette.maskColor
            chartRenderer.addSubview(detailsMaskView)
            detailsMaskLayer = CAShapeLayer()
        case .point:
            channels.enumerated().forEach {
                let channelIndex = $0.offset

                guard !disabledChannelIndexes.contains(channelIndex) else { return }

                let pointLayer = CAShapeLayer()
                pointLayer.fillColorPalette = .backgroundContentColor
                pointLayer.lineWidth = 4 / UIScreen.main.scale
                pointLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 6, height: 6), cornerRadius: 3).cgPath
                layer.addSublayer(pointLayer)
                detailsPointsLayers[channelIndex] = pointLayer
            }
        case .none:
            break
        }

        moveDetailsView(to: location, animated: false)
    }

    private func moveDetailsView(to location: CGPoint, animated: Bool) {
        guard !timestamps.isEmpty else { return }

        let newSelectedIndex = viewport.closestIndex(to: viewport.translateLeft - location.x / viewport.size.width)
        guard selectedIndex != newSelectedIndex else {
            return
        }
        selectedIndex = newSelectedIndex

        let locationX = viewport.spacingX * CGFloat(newSelectedIndex) + viewport.translateLeft * viewport.size.width
        lastX = locationX

        let lineWidth: CGFloat = 1.0

        let enabledChannels = channels
            .enumerated()
            .filter { !disabledChannelIndexes.contains($0.offset) }
            .map { $0.element }
        detailsView.setValues(
            enabledChannels.map { $0.values[newSelectedIndex] },
            coloredIn: enabledChannels.map { $0.color },
            namedAs: enabledChannels.map { $0.name },
            timestamp: timestamps[newSelectedIndex]
        )
        var originX = locationX - detailsViewOffset - detailsView.frame.width
        if originX < detailsViewOffset {
            originX += detailsView.frame.width + detailsViewOffset * 2
        }

        let animationBlock = {
            self.detailsView.frame.origin = CGPoint(
                x: originX,
                y: self.insets.top + detailsViewOffset
            )
        }

        if (animated) {
            UIView.animateKeyframes(
                withDuration: 0.15,
                delay: 0,
                options: [.beginFromCurrentState],
                animations: {
                    animationBlock()
                },
                completion: nil
            )
        } else {
            animationBlock()
        }

        // Pointer

        switch chartRenderer.selectionType {
        case .mask:
            detailsMaskView.frame = CGRect(
                x: 0,
                y: 0,
                width: viewport.size.width,
                height: viewport.size.height
            )
            let path = UIBezierPath(rect: CGRect(
                x: 0.0,
                y: 0,
                width: locationX - viewport.spacingX / 2,
                height: viewport.size.height
                )
            )
            path .append(UIBezierPath(rect: CGRect(
                x: locationX + viewport.spacingX / 2,
                y: 0,
                width: viewport.size.width - locationX - viewport.spacingX / 2,
                height: viewport.size.height
                )
            ))
            detailsMaskLayer.path = path.cgPath
            detailsMaskView.layer.mask = detailsMaskLayer
        case .point:
            if (chartRenderer.selectionType == .point) {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)
                CATransaction.setDisableActions(!animated)
                channels.enumerated().forEach {
                    let channelIndex = $0.offset
                    let channel = $0.element

                    guard !disabledChannelIndexes.contains(channelIndex) else { return }

                    let pointLayer = detailsPointsLayers[channelIndex]!
                    pointLayer.strokeColor = channel.color.cgColor
                    let realIndex = min(channelIndex, yCalculator.ysCount - 1)
                    pointLayer.frame = CGRect(
                        origin: CGPoint(
                            x: locationX - 3,
                            y: viewport.y(for: channel.values[newSelectedIndex], at: realIndex) - 3
                        ),
                        size: CGSize(width: 6, height: 6)
                    )
                }
                CATransaction.commit()
            }
            fallthrough
        case .none:
            self.detailsPointerView.frame = CGRect(
                x: locationX - lineWidth / 2,
                y: self.insets.top,
                width: lineWidth,
                height: self.viewport.size.height - self.insets.top
            )
        }
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        guard lastBounds != bounds.size else { return }
        lastBounds = bounds.size

        let legendXHeightToCount = legendXRenderer != nil ? legendXHeight : 0

        chartRenderer.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height - legendXHeightToCount
        )
        viewport.size = chartRenderer.frame.size

        legendXRenderer?.frame = CGRect(
            x: 0,
            y: bounds.height - legendXHeight,
            width: bounds.width,
            height: legendXHeight
        )
        legendXRenderer?.layoutSubviews()

        legendYRenderer?.frame = CGRect(
            x: contentInset,
            y: 0,
            width: bounds.width - contentInset * 2,
            height: bounds.height - legendXHeightToCount
        )
        legendYRenderer?.layoutSubviews()

        dashLabel.sizeToFit()
        dashLabel.frame = CGRect(
            x: bounds.width / 2 - dashLabel.frame.width / 2, y: 8,
            width: dashLabel.frame.width, height: 20
        )
        rightDateLabel.frame = CGRect(
            x: dashLabel.frame.maxX + 2, y: 8,
            width: (bounds.width - dashLabel.frame.width - 4) / 2, height: 20
        )
        leftDateLabel.frame = CGRect(
            x: 0, y: 8,
            width: (bounds.width - dashLabel.frame.width - 4) / 2, height: 20
        )

        updateDefaults()
    }
}

extension ChartView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer
            else { return true }

        let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
    }
}

let topDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM yyyy"
    dateFormatter.locale = .autoupdatingCurrent
    return dateFormatter
}()
