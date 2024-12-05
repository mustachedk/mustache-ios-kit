#if canImport(UIKit)

import UIKit

public extension UINavigationController {

    // MARK: STACK
    var topNavigationController: UINavigationController {
        if let presentedViewController = self.presentedViewController as? UINavigationController {
            return presentedViewController.topNavigationController
        } else {
            return self
        }
    }
    
    // MARK: PUSH

    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> ()) {
        self.pushViewController(viewController, animated: animated)

        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }
    
    func pushViewController(_ viewController: UIViewController, at index: Int, animated: Bool){
        var viewControllers = self.viewControllers
        let index = min(index, viewControllers.endIndex)
        viewControllers.insert(viewController, at: index)
        self.setViewControllers(viewControllers, animated: true)
    }
    
    // MARK: POP

    func popViewController(animated: Bool, completion: @escaping  () -> ()) {
        self.popViewController(animated: animated)
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }
    
    @discardableResult
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) -> [UIViewController]? {
        let controllers = self.popToViewController(viewController, animated: animated)
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() })
        } else {
            completion()
        }
        return controllers
    }

    func popToRootViewController(animated: Bool, completion: @escaping  () -> ()) {
        self.popToRootViewController(animated: animated)
        if let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in }, completion: { _ in completion() } )
        } else {
            completion()
        }
    }
    
    /// Pops view controllers until the one specified is on top. Returns the popped controllers.
    @discardableResult
    func popToViewControllerOf<T: UIViewController>(_ type: T.Type, animated: Bool, completion: @escaping () -> ()) -> [UIViewController]? {
        guard let viewController = self.viewControllers.first(where: { $0 is T }) else { return nil }
        return self.popToViewController(viewController, animated: animated, completion: completion)
    }
    
    // MARK: REMOVE
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
    
   
}

#endif
