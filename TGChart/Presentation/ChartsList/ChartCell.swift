import UIKit

let chartHeight = UIScreen.main.bounds.width * 0.8
let contentInset: CGFloat = 16

private let intervalHeight: CGFloat = 44
private let contentOffsetY: CGFloat = 8
private let selectId = "select"

final class ChartCell: UITableViewCell {

    private let chartView: NewChartView
    private let intervalView: ChartIntervalView
    private let selectorCollectionView: UICollectionView

    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    private var selectedIndexes: IndexSet

    var preferredHeight: CGFloat = 0
    private let cellHeights: [CGFloat]

    private let dataSet: DataSet

    init(
        dataSet: DataSet,
        chartRenderer: ChartRenderer,
        intervalChartRenderer: ChartRenderer,
        calculator: YCalculator,
        legendYRenderer: LegendYRenderer,
        legendXRenderer: LegendXRenderer,
        chartInsets: UIEdgeInsets,
        intervalInsets: UIEdgeInsets
    ) {
        self.dataSet = dataSet
        selectedIndexes = IndexSet(dataSet.channels.enumerated().map({ iter -> Int in
            return iter.offset
        }))

        chartView = NewChartView(
            insets: chartInsets,
            yCalculator: calculator,
            chartRenderer: chartRenderer,
            legendXRenderer: legendXRenderer,
            legendYRenderer: legendYRenderer,
            detailsEnabled: true
        )
        chartView.setDataSet(dataSet)
        intervalView = ChartIntervalView(
            chartView: NewChartView(
                insets: intervalInsets,
                yCalculator: calculator,
                chartRenderer: intervalChartRenderer,
                legendXRenderer: nil,
                legendYRenderer: nil,
                detailsEnabled: false
            )
        )
        intervalView.chartView.setDataSet(dataSet)
        intervalView.onIntervalChange = { [weak chartView] newIntervalX in
            chartView?.intervalX = Interval(min: newIntervalX.min, max: newIntervalX.max)
        }

        let flowLayout = DataSelectorFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 12
        selectorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        selectorCollectionView.backgroundColor = .clear
        selectorCollectionView.clipsToBounds = false

        cellHeights = dataSet.channels.map { DataSelectorCollectionViewCell.width(for: $0.name) }

        super.init(style: .default, reuseIdentifier: nil)

        backgroundPalette = Palette.backgroundContentColor

        selectionStyle = .none

        contentView.addSubview(chartView)

        contentView.addSubview(intervalView)

        selectorCollectionView.delegate = self
        selectorCollectionView.dataSource = self
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        selectorCollectionView.addGestureRecognizer(longPressGestureRecognizer)
        selectorCollectionView.register(DataSelectorCollectionViewCell.self, forCellWithReuseIdentifier: selectId)
        contentView.addSubview(selectorCollectionView)

        var height = chartHeight + contentOffsetY
        height += intervalHeight + contentOffsetY
        if dataSet.channels.count > 1 {
            selectorCollectionView.frame = CGRect(
                origin: .zero,
                size: CGSize(
                    width: UIScreen.main.bounds.width - contentInset * 2,
                    height: 1000
                )
            )
            selectorCollectionView.reloadData()
            selectorCollectionView.layoutIfNeeded()
            height += selectorCollectionView.contentSize.height + contentOffsetY
        }
        preferredHeight = height;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentWidth = UIScreen.main.bounds.width - contentInset * 2

        chartView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: chartHeight)
        intervalView.frame = CGRect(
            x: contentInset,
            y: chartView.frame.maxY + contentOffsetY,
            width: contentWidth,
            height: intervalHeight
        )
        selectorCollectionView.frame = CGRect(
            x: contentInset,
            y: intervalView.frame.maxY + contentOffsetY,
            width: contentWidth,
            height: selectorCollectionView.contentSize.height
        )
    }

    @objc
    private func handleLongTap() {
        let location = longPressGestureRecognizer.location(in: selectorCollectionView)
        guard let indexPath = selectorCollectionView.indexPathForItem(at: location) else {
            return
        }
        deselectAllBut(indexPath.row)
    }

    private func deselectAllBut(_ index: Int) {
        enableChannels(
            at: selectedIndexes.contains(index) ? [] : [index],
            disableAt: selectedIndexes.filter { $0 != index }
        )
        selectedIndexes.removeAll()
        selectedIndexes.insert(index)
        selectorCollectionView.indexPathsForVisibleItems.forEach { indexPath in
            let cell = selectorCollectionView.cellForItem(at: indexPath) as! DataSelectorCollectionViewCell
            cell.setSelected(indexPath.row == index, animated: true)
        }
    }

    private func enableChannels(at indexes: [Int]) {
        chartView.enableChannels(at: indexes)
        intervalView.chartView.enableChannels(at: indexes)
    }

    private func disableChannels(at indexes: [Int]) {
        chartView.disableChannels(at: indexes)
        intervalView.chartView.disableChannels(at: indexes)
    }

    private func enableChannels(
        at indexesToEnable: [Int],
        disableAt indexesToDisable: [Int]
    ) {
        chartView.enableChannels(at: indexesToEnable, disableAt: indexesToDisable)
        intervalView.chartView.enableChannels(at: indexesToEnable, disableAt: indexesToDisable)
    }
}

extension ChartCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSet.channels.count > 1 ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSet.channels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectId, for: indexPath) as! DataSelectorCollectionViewCell
        let channel = dataSet.channels[indexPath.row]
        cell.setText(channel.name, color: channel.color)
        let isSelected = selectedIndexes.contains(indexPath.row)
        cell.setSelected(isSelected, animated: false)
        return cell
    }

    //MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: cellHeights[indexPath.row],
            height: dataSelectorCellHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DataSelectorCollectionViewCell

        let wasSelected = selectedIndexes.contains(indexPath.row)
        if (wasSelected) {
            if selectedIndexes.count == 1 {
                let animation = CABasicAnimation(keyPath: "position.x")
                animation.duration = 0.08
                animation.repeatCount = 2
                animation.autoreverses = true
                animation.fromValue = cell.center.x - 2
                animation.toValue = cell.center.x + 2
                cell.layer.add(animation, forKey: nil)

                if #available(iOS 10, *) {
                    let generator = UISelectionFeedbackGenerator()
                    generator.prepare()
                    generator.selectionChanged()
                }
            } else {
                selectedIndexes.remove(indexPath.row)
                disableChannels(at: [indexPath.row])
                cell.setSelected(false, animated: true)
            }
        } else {
            selectedIndexes.insert(indexPath.row)
            enableChannels(at: [indexPath.row])
            cell.setSelected(true, animated: true)
        }
    }
}
