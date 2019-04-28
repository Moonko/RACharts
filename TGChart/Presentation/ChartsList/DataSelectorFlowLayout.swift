import UIKit

final class DataSelectorFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        guard scrollDirection == .vertical else { return layoutAttributes }

        guard let cellAttributes = layoutAttributes?.filter({ $0.representedElementCategory == .cell }) else {
            return layoutAttributes
        }

        Dictionary(grouping: cellAttributes) { $0.center.y }.values.forEach { attributes in
            var leftInset: CGFloat = 0
            attributes.forEach { attribute in
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }

        return layoutAttributes
    }
}
