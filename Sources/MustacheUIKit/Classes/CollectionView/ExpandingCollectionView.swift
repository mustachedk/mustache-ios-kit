
#if canImport(UIKit)
import Foundation
import UIKit

/// A collection that will expand so that frame.size equals bounds.size
open class ExpandingCollectionView: UICollectionView {

    override open func reloadData() {
        self.collectionViewLayout.invalidateLayout()
        super.reloadData()
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if !self.bounds.size.equalTo(self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }

    override open var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        var intrinsicContentSize = super.contentSize
        intrinsicContentSize.height += (self.contentInset.top + self.contentInset.bottom)
        intrinsicContentSize.width += (self.contentInset.left + self.contentInset.right)
        return intrinsicContentSize
    }

}
#endif
