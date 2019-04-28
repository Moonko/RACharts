import UIKit

private let maxTimestampWidth: CGFloat = 40

final class FloatingLegendXRenderer: UIView, LegendXRenderer {

    var needsRendering: Bool = false

    var viewport: Viewport!

    private var timestampsFadeInAnimator: AlphaAnimator!
    private var timestampsToFadeIn = [Int: UILabel]()

    private var timestampsFadeOutAnimator: AlphaAnimator!
    private var timestampsToFadeOut = [Int: UILabel]()

    private var drawnTimestampIndexes = IndexSet()

    private var timestamps = [Timestamp]()

    private var drawables = [UILabel]()

    private var firstIndex: Int = -1
    private var lastIndex: Int = 0

    private var labelsCache = [Int: UILabel]()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        timestampsFadeInAnimator = AlphaAnimator() { newAlpha in
            if newAlpha >= 1 {
                self.timestampsToFadeIn.removeAll()
            }
            self.timestampsToFadeIn.values.forEach { $0.alpha = newAlpha }
            self.needsRendering = true
        }

        timestampsFadeOutAnimator = AlphaAnimator() { newAlpha in
            if newAlpha <= 0.01 {
                self.timestampsToFadeOut.values.forEach {
                    $0.removeFromSuperview()
                }
                self.timestampsToFadeOut.removeAll()
            }
            self.timestampsToFadeOut.values.forEach { $0.alpha = newAlpha }
            self.needsRendering = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTimestamps(_ timestamps: [Timestamp]) {
        self.timestamps = timestamps
    }

    func update(from fromIndex: Int, to toIndex: Int) {
        var knownIndexes = IndexSet()

        let relTimestampWidth = maxTimestampWidth / viewport.size.width

        let fromIndex = viewport.closestIndex(to: viewport.translateLeft + relTimestampWidth)
        let toIndex = viewport.closestIndex(to: viewport.translateLeft - 1 - relTimestampWidth)

        if (firstIndex == -1) {
            firstIndex = Int(ceil((maxTimestampWidth / 2) / viewport.spacingX))
            lastIndex = timestamps.count - 1 - firstIndex
        }

        let calc1 = 0
        let calc2 = firstIndex
        let calc3 = lastIndex
        let calc4 = timestamps.count

        guard fromIndex != toIndex else { return }

        var curIndexes = IndexSet()

        curIndexes.insert(firstIndex)
        curIndexes.insert(lastIndex)

        func calcVisibleIndeces(from: Int, to: Int) {
            let distance = CGFloat(to - from) * viewport.spacingX
            let middleIndex = from + (to - from) / 2
            if (distance >= maxTimestampWidth * 2) {
                curIndexes.insert(middleIndex)
                calcVisibleIndeces(from: from, to: middleIndex)
                calcVisibleIndeces(from: middleIndex, to: to)
            }
        }

        calcVisibleIndeces(from: calc1, to: calc2)
        calcVisibleIndeces(from: calc2, to: calc3)
        calcVisibleIndeces(from: calc3, to: calc4)

        (fromIndex ..< toIndex).forEach {
            if curIndexes.contains($0) {
                knownIndexes.insert($0)
            }
        }

        if (drawnTimestampIndexes.isEmpty) {
            drawnTimestampIndexes = knownIndexes
        }

        var toDraw = [Int: UILabel]()

        let newIndexes = knownIndexes.subtracting(drawnTimestampIndexes)
        if !newIndexes.isEmpty {
            timestampsToFadeIn.values.forEach {
                $0.alpha = 1.0
            }
            timestampsToFadeIn.removeAll()
            timestampsFadeInAnimator.animate(0.0, toValue: 1.0)
        }
        newIndexes.forEach { index in
            timestampsToFadeIn[index] = labelFromCache(index, alpha: 0.0)
        }
        timestampsToFadeIn.forEach {
            toDraw[$0] = $1
        }

        let oldIndexes = drawnTimestampIndexes.subtracting(knownIndexes)
        if !oldIndexes.isEmpty {
            timestampsToFadeOut.values.forEach {
                $0.removeFromSuperview()
            }
            timestampsToFadeOut.removeAll()
            timestampsFadeOutAnimator.animate(1.0, toValue: 0.0)
        }
        oldIndexes.forEach { index in
            timestampsToFadeOut[index] = labelFromCache(index, alpha: 1)
        }
        timestampsToFadeOut.forEach {
            toDraw[$0] = $1
        }

        knownIndexes
            .filter { !timestampsToFadeIn.keys.contains($0) }
            .forEach { index in
                toDraw[index] = labelFromCache(index, alpha: 1)
            }

        drawnTimestampIndexes = knownIndexes

        toDraw.keys.forEach {
            let labelX = (viewport.spacingX * CGFloat($0)) + viewport.translateLeft * viewport.size.width
            toDraw[$0]?.frame.origin.x = labelX - maxTimestampWidth / 2
        }
        self.drawables = Array(toDraw.values)
    }

    func labelFromCache(_ index: Int, alpha: CGFloat) -> UILabel {
        var labelToReturn: UILabel
        if let cachedLabel = labelsCache[index] {
            labelToReturn = cachedLabel
        } else {
            labelToReturn = UILabel()
            labelToReturn.text = timestampDateFormatter.string(from: timestamps[index])
            labelToReturn.textColorPalette = .captionColor
            labelToReturn.textAlignment = .center
            labelToReturn.frame.origin.y = 4
            labelToReturn.frame.size = CGSize(width: maxTimestampWidth, height: 16)
            labelToReturn.font = .systemFont(ofSize: 10)
            labelsCache[index] = labelToReturn
        }
        labelToReturn.alpha = alpha
        addSubview(labelToReturn)
        return labelToReturn
    }
}

let timestampDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    dateFormatter.locale = Locale(identifier: "en")
    return dateFormatter
}()
