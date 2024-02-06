#if canImport(UIKit)

import UIKit

extension UIWindow {

    /**

    Method for getting the top view controller in the hierarchy

    - returns:
    UIViewController?

    */
    public func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

#endif
