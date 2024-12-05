
#if canImport(UIKit)
import Foundation
import UIKit

public final class SwipeNavigationController: UINavigationController {

    private var isHidden: Bool = true
    
    // MARK: - Lifecycle

    var _preferredInterfaceOrientationForPresentation: UIInterfaceOrientation = .portrait
    var _supportedInterfaceOrientations: UIInterfaceOrientationMask = [.portrait]
    weak var forwardingDelegate: UINavigationControllerDelegate? = nil

    override public var delegate: UINavigationControllerDelegate? {
        set {
            self.forwardingDelegate = newValue
        } get {
            return self.forwardingDelegate
        }
    }
    
    convenience public init(forwardingDelegate: UINavigationControllerDelegate?, isHidden: Bool = true) {
        self.init(nibName: nil, bundle: nil)
        super.delegate = self
        self.forwardingDelegate = forwardingDelegate
        self.isHidden = isHidden
    }

    convenience public init() {
        self.init(nibName: nil, bundle: nil)
        super.delegate = self
    }

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        super.delegate = self
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        super.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    func configure() {
        self.interactivePopGestureRecognizer?.delegate = self
        self.setNavigationBarHidden(self.isHidden, animated: false)
    }

    deinit {
        self.delegate = nil
        self.interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Overrides

    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Private Properties

    fileprivate var duringPushAnimation = false

}

// MARK: - UINavigationControllerDelegate

extension SwipeNavigationController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.forwardingDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? SwipeNavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
        self.forwardingDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.forwardingDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? self._supportedInterfaceOrientations
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return self.forwardingDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? self._preferredInterfaceOrientationForPresentation
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.forwardingDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.forwardingDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }

}

// MARK: - UIGestureRecognizerDelegate

extension SwipeNavigationController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.interactivePopGestureRecognizer else { return true } // default value

        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return self.viewControllers.count > 1 && self.duringPushAnimation == false
    }
}
#endif
