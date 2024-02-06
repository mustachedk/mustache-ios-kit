#if canImport(UIKit)

import UIKit

public extension UICollectionViewCell {

    /// Convenience identifier for UICollectionViewCell
    override class var identifier: String { return String(describing: self) }

    /**
        This is a workaround method for self sizing collection view cells which stopped working for iOS 12
        Should be called from:
        func awakeFromNib()

        - parameters:
            -contentView: UIView

    */
    func setupSelfSizingForiOS12(contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
}
#endif
