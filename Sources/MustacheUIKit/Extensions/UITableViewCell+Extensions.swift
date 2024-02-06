#if canImport(UIKit)
import UIKit

public extension UITableViewCell {

    /// Convenience identifier for UITableViewCell
    class var identifier: String { return String(describing: self) }

}
#endif
