import UIKit

final class HeaderView: UITableViewHeaderFooterView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColorPalette = Palette.headerColor
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(
            x: layoutMargins.left,
            y: contentView.bounds.height - titleLabel.bounds.height - 8
        )
    }
}
