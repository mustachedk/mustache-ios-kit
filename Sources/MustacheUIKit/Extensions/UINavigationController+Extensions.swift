#if canImport(UIKit)

import UIKit

public extension UINavigationController {

    var topNavigationController: UINavigationController {
        if let presentedViewController = self.presentedViewController as? UINavigationController {
            return presentedViewController.topNavigationController
        } else {
            return self
        }
    }

    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> ()) {
        self.pushViewController(viewController, animated: animated)

        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping  () -> ()) {
        self.popViewController(animated: animated)
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }

    func popToRootViewController(animated: Bool, completion: @escaping  () -> ()) {
        self.popToRootViewController(animated: animated)
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }
}

#endif
