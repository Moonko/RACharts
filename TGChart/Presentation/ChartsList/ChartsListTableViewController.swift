import UIKit

private let chartRenderers: [ChartRenderer] = [
    LineChartRenderer(lineWidth: 1 * UIScreen.main.scale),
    LineChartRenderer(lineWidth: 1 * UIScreen.main.scale),
    StackedBarChartRenderer(),
    StackedBarChartRenderer(),
    PercentStackedAreaChartRenderer()
]

private let intervalChartRenderers: [ChartRenderer] = [
    LineChartRenderer(lineWidth: 1 * UIScreen.main.scale),
    LineChartRenderer(lineWidth: 1 * UIScreen.main.scale),
    StackedBarChartRenderer(),
    StackedBarChartRenderer(),
    PercentStackedAreaChartRenderer()
]

private let calculators: [YCalculator] = [
    CommonYCalculator(),
    SeparateYCalculator(),
    SumYCalculator(),
    SumYCalculator(),
    PercentYCalculator()
]

private let legendYRenderers: [LegendYRenderer] = [
    FloatingLegendYRenderer(valuesCount: 7, showsTopValue: false),
    FloatingLegendYRenderer(valuesCount: 7, showsTopValue: false),
    FloatingLegendYRenderer(valuesCount: 7, showsTopValue: false),
    FloatingLegendYRenderer(valuesCount: 7, showsTopValue: false),
    FloatingLegendYRenderer(valuesCount: 5, showsTopValue: true),
]

private let chartInsets: [UIEdgeInsets] = [
    UIEdgeInsets(top: 36, left: 16, bottom: 20, right: 16),
    UIEdgeInsets(top: 36, left: 16, bottom: 20, right: 16),
    UIEdgeInsets(top: 36, left: 16, bottom: 0, right: 16),
    UIEdgeInsets(top: 36, left: 16, bottom: 0, right: 16),
    UIEdgeInsets(top: 36, left: 16, bottom: 0, right: 16)
]

private let intervalInsets: [UIEdgeInsets] = [
    UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0),
    UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0),
    UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0),
    UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0),
    UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
]

private let headerViews: [UIView] = [
    {
        let view = HeaderView()
        view.setTitle("FOLLOWERS")
        return view
    }(),
    {
        let view = HeaderView()
        view.setTitle("INTERACTIONS")
        return view
    }(),
    {
        let view = HeaderView()
        view.setTitle("FRUIT BARS")
        return view
    }(),
    {
        let view = HeaderView()
        view.setTitle("VIEWS")
        return view
    }(),
    {
        let view = HeaderView()
        view.setTitle("FRUIT AREAS")
        return view
    }()
]

class ChartsListTableViewController: UITableViewController {

    private let chartCells: [ChartCell]

    init() {
        let chartsCount = 5
        self.chartCells = (0 ..< chartsCount).map { index in
            let jsonURL = Bundle.main.url(forResource: "\(index + 1)", withExtension: "json")!
            let jsonData = try! Data(contentsOf: jsonURL)
            let dataSetObj = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! Dictionary<String, Any>
            var columnObjects = dataSetObj["columns"] as! [[Any]]
            let nameObjects = dataSetObj["names"] as! Dictionary<String, String>
            let colorObjects = dataSetObj["colors"] as! Dictionary<String, String>
            let yScaled = dataSetObj["y_scaled"] as? Bool ?? false
            let percentage = dataSetObj["percentage"] as? Bool ?? false
            let stacked = dataSetObj["stacked"] as? Bool ?? false

            var timestampObjects = columnObjects.removeFirst()
            timestampObjects.removeFirst()

            let dataSet = DataSet(
                channels: columnObjects.map { values -> Channel in
                    var mutValues = values
                    let key = mutValues.removeFirst() as! String
                    return Channel(
                        name: nameObjects[key]!,
                        color: .hex(Int(colorObjects[key]!.replacingOccurrences(of: "#", with: ""), radix: 16)!),
                        values: mutValues as! [ChannelValue]
                    )
                },
                timestamps: (timestampObjects as! [NSNumber]).map { Date(timeIntervalSince1970: TimeInterval($0.doubleValue) / 1000) },
                percentage: percentage,
                stacked: stacked,
                yScaled: yScaled
            )

            return ChartCell(
                dataSet: dataSet,
                chartRenderer: chartRenderers[index],
                intervalChartRenderer: intervalChartRenderers[index],
                calculator: calculators[index],
                legendYRenderer: legendYRenderers[index],
                legendXRenderer: FloatingLegendXRenderer(),
                chartInsets: chartInsets[index],
                intervalInsets: intervalInsets[index]
            )
        }

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundPalette = Palette.backgroundPageColor
        tableView.separatorColorPalette = Palette.separatorColor
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        tableView.showsVerticalScrollIndicator = false

        title = "Statistics"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(changeTheme))
        updateRightBarButtonItem()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = CGRect(origin: tableView.frame.origin, size: CGSize(width: tableView.frame.width, height: tableView.contentSize.height))
        var safeInset: CGFloat = 20
        if #available(iOS 11, *) {
            safeInset += view.safeAreaInsets.bottom == 0 ? 40 : view.safeAreaInsets.bottom
        } else {
            safeInset += 60
        }
        tableView.contentInset.bottom = tableView.contentSize.height - UIScreen.main.bounds.height + safeInset
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return chartCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return chartCells[indexPath.section]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return chartCells[indexPath.section].preferredHeight
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    // MARK: Theme change

    @objc
    private func changeTheme() {
        ThemeSelector.chooseNextTheme()
        updateRightBarButtonItem()
        if (!(tableView.isTracking || tableView.isDragging || tableView.isDecelerating)) {
            ThemeSelector.animateThemeChange()
        }
    }

    private func updateRightBarButtonItem() {
        navigationItem.rightBarButtonItem?.title = "\(ThemeSelector.nextThemeName) mode"
    }
}


struct Channel {

    let name: String
    let color: UIColor
    let values: [ChannelValue]
}

typealias ChannelValue = CGFloat
typealias Timestamp = Date

struct DataSet {

    let channels: [Channel]
    let timestamps: [Timestamp]

    let percentage: Bool
    let stacked: Bool
    let yScaled: Bool
}
