#if canImport(UIKit)
import Foundation
import UIKit

public protocol CustomTransitioningDelegate {
    
    var isPresentingAnimated: Bool { get }
    var isDismissedAnimated: Bool { get }
    var transitioningDelegate: UIViewControllerTransitioningDelegate { get }
    
}

public extension CustomTransitioningDelegate {
    var isPresentingAnimated: Bool { true }
    var isDismissedAnimated: Bool { true }
}

#endif
