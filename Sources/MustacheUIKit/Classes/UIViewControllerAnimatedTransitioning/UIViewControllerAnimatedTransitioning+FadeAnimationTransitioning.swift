
import Foundation
import UIKit

public protocol FadingTransition: CustomTransitioningDelegate {}

public extension FadingTransition {
    
    var transitioningDelegate: UIViewControllerTransitioningDelegate {
        return FadingTransitionDelegate(isPresentingAnimated: self.isPresentingAnimated, isDismissedAnimated: self.isDismissedAnimated)
    }
    
}

public class FadingTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public var isPresentingAnimated: Bool
    public var isDismissedAnimated: Bool
    
    public init(isPresentingAnimated: Bool = true, isDismissedAnimated: Bool = true) {
        self.isPresentingAnimated = isPresentingAnimated
        self.isDismissedAnimated = isDismissedAnimated
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingAnimationController(animated: self.isPresentingAnimated, isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingAnimationController(animated: self.isDismissedAnimated, isPresenting: false)
    }
    
}

public class FadingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
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
            
            containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: duration, animations: {
                toViewController.view.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
            
        } else {
            
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            UIView.animate(withDuration: duration, animations: {
                fromViewController.view.alpha = 0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}
