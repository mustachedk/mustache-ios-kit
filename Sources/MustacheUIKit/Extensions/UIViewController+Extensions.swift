#if canImport(UIKit)

import UIKit
import MustacheFoundation

public extension UIViewController {

    /// Is this UIViewController presented modally, dont only count on this variable
    var isModal: Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }

    /// Convenience storyboardID for UIViewController
    class var storyboardID: String { return "\(self)" }

    /**
    Presents an alert

    - parameters:
        - title: String
        - message: String default = ""
        - okAction: (() -> Void)? action when user dismisses the alert
        - cancelAction: (() -> Void)? action when user cancels the alert
        - okButtonTitle: String
        - cancelButtonTitle: String

    */
    @available(*, deprecated, message: "Use UIAlertController.alert or UIAlertController.sheet instead")
    func alert(title: String?,
               message: String?,
               okAction: (@escaping () -> Void) = {},
               okButtonTitle: String = "OK",
               destructiveAction: (() -> Void)? = nil,
               destructiveButtonTitle: String? = nil,
               cancelAction: (() -> Void)? = nil,
               cancelButtonTitle: String? = nil) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: okButtonTitle, style: .default, handler: { [okAction] _ in okAction() })
        alertController.addAction(OKAction)
        
        // UIAlertAction can be created without title but it will crash on iPhone
        
        if let destructiveAction = destructiveAction, let destructiveButtonTitle = destructiveButtonTitle {
            let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .destructive, handler: { [destructiveAction] _ in destructiveAction() })
            alertController.addAction(destructiveAction)
        }
        
        if let cancelAction = cancelAction, let cancelButtonTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { [cancelAction] _ in cancelAction() })
            alertController.addAction(cancelAction)
        }

        self.present(alertController, animated: true, completion: nil)
    }

    /**
    Adds a child view controller and animates it in

    - parameters:
        - child: UIViewController

    */
    func add(child controller: UIViewController) {

        controller.view.alpha = 0

        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)

        UIView.animate(withDuration: 0.3) { () -> Void in
            controller.view.alpha = 1
        }
    }

    /**
    Removes a child view controller and animates it out

    - parameters:
        - child: UIViewController

    */
    func remove(child controller: UIViewController) {

        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            controller.view.alpha = 0
        }, completion: { b in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        })
    }

    /**
    Removes all child view controllers and animates them out

    */
    func removeChildren() {

        let children = self.children

        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            for child in children {
                child.view.alpha = 0
            }
        }, completion: { b in
            for child in children {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        })
    }

}

#endif
