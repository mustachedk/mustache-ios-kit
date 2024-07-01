#if canImport(UIKit)
import Foundation
import UIKit

public  class SlidingTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.3

    public init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
                else {
            transitionContext.completeTransition(false)
            return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: { success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController controller: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        return vcs.firstIndex(where: { $0 == controller })
    }
}
#endif
