#if canImport(UIKit)
import UIKit

public extension UICollectionReusableView {

    /// Convenience identifier for UICollectionReusableView
    @objc class var identifier: String { return String(describing: self) }
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }

}
#endif
