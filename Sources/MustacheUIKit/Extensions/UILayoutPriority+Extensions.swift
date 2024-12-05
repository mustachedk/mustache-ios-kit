#if canImport(UIKit)

import UIKit

public extension UILayoutPriority {

    /**
    Convience method for changing a UILayoutPriority

    - returns:
    UILayoutPriority

    - parameters:
        - lhs: UILayoutPriority
        - rhs: Float

    */
    static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue + rhs)
    }

    /**
    Convience method for changing a UILayoutPriority

    - returns:
    UILayoutPriority

    - parameters:
        - lhs: UILayoutPriority
        - rhs: Float

    */
    static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue - rhs)
    }
}

#endif
