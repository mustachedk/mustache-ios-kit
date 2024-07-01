#if canImport(UIKit)
import Foundation
import UIKit

public protocol ModalPushPopTransition: CustomTransitioningDelegate {}

public extension ModalPushPopTransition {
    
    var transitioningDelegate: UIViewControllerTransitioningDelegate {
        return ModalPushPopTransitionDelegate(isPresentingAnimated: self.isPresentingAnimated, isDismissedAnimated: self.isDismissedAnimated)
    }
    
}

public class ModalPushPopTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public var isPresentingAnimated: Bool
    public var isDismissedAnimated: Bool
    
    public init(isPresentingAnimated: Bool = true, isDismissedAnimated: Bool = true) {
        self.isPresentingAnimated = isPresentingAnimated
        self.isDismissedAnimated = isDismissedAnimated
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPushPopAnimationController(animated: self.isPresentingAnimated, isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPushPopAnimationController(animated: self.isDismissedAnimated, isPresenting: false)
    }
    
}

public class ModalPushPopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var animated: Bool
    public var isPresenting: Bool
    
    public init(animated: Bool, isPresenting: Bool) {
        self.animated = animated
        self.isPresenting = isPresenting
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animated ? 0.3 : 0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        if self.isPresenting {
            
            toViewController.view.frame = containerView.frame.offsetBy(dx: 0, dy: containerView.frame.height)
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                toViewController.view.frame = fromViewController.view.frame
            },
                           completion: { _ in
                transitionContext.completeTransition(true)
            })
            
        } else {
            
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [UIView.AnimationOptions.curveEaseInOut],
                           animations: {
                fromViewController.view.frame = containerView.frame.offsetBy(dx: 0, dy: containerView.frame.height)
            },
                           completion: { _ in
                transitionContext.completeTransition(true)
            })
            
        }
    }
    
}
#endif
