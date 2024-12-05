
#if canImport(UIKit)

import UIKit

public extension NSLayoutConstraint {

    /**
    Change NSLayoutConstraint multiplier

    - returns:
    A new NSLayoutConstraint with the change multiplier

    - parameters:
        - multiplier: CGFloat

    */

    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
#endif
