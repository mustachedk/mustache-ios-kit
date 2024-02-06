//:
//:  UIView Animation Syntax Sugar
//:
//:  Created by Andyy Hope on 18/08/2016.
//:  Twitter: @andyyhope
//:  Medium: Andyy Hope, https://medium.com/@AndyyHope
#if canImport(UIKit)
import UIKit

public extension UIView {
    
    class Animator {
        
        public typealias Completion = (Bool) -> Void
        public typealias Animations = () -> Void
        
        fileprivate var animations: Animations
        fileprivate var completion: Completion?
        fileprivate let duration: TimeInterval
        fileprivate let delay: TimeInterval
        fileprivate let options: UIView.AnimationOptions
        
        public init(duration: TimeInterval, delay: TimeInterval = 0, options: UIView.AnimationOptions = []) {
            
            self.animations = {}
            self.completion = nil
            self.duration = duration
            self.delay = delay
            self.options = options
        }
        
        public func animations(_ animations: @escaping Animations) -> Self {
            self.animations = animations
            return self
        }
        
        public func completion(_ completion: @escaping Completion) -> Self {
            self.completion = completion
            return self
        }
        
        public func animate() {
            UIView.animate(withDuration: duration, delay: delay, animations: animations, completion: completion)
        }
    }
    
    final class SpringAnimator: Animator {
        
        fileprivate let damping: CGFloat
        fileprivate let velocity: CGFloat
        
        public init(duration: TimeInterval, delay: TimeInterval = 0, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions = []) {
            self.damping = damping
            self.velocity = velocity
            
            super.init(duration: duration, delay: delay, options: options)
        }
        
        override public func animate() {
            UIView.animate(withDuration: self.duration,
                           delay: self.delay,
                           usingSpringWithDamping: self.damping,
                           initialSpringVelocity: self.velocity,
                           options: self.options,
                           animations: self.animations,
                           completion: self.completion)
        }
    }
}


// MARK: - Example API

// var view = UIView(frame: .zero)
//
//
// // Regular Animations
//
// func UIView.Animator(duration: 0.3)
//     .animations {
//         view.frame.size.height = 100
//         view.frame.size.width = 100
//     }
//     .completion { finished in
//         view.backgroundColor = .black
//     }
//     .animate()
//
//
// // Regular Animations with options
//
// UIView.Animator(duration: 0.4, delay: 0.2)
//     .animations { }
//     .completion { _ in }
//     .animate()
//
// UIView.Animator(duration: 0.4, options: [.autoreverse, .curveEaseIn])
//     .animations { }
//     .completion { _ in }
//     .animate()
//
// UIView.Animator(duration: 0.4, delay: 0.2, options: [.autoreverse, .curveEaseIn])
//     .animations { }
//     .completion { _ in }
//     .animate()
//
// // Spring Animator
//
// UIView.SpringAnimator(duration: 0.3, delay: 0.2, damping: 0.2, velocity: 0.2, options: [.autoreverse, .curveEaseIn])
//     .animations { }
//     .completion { _ in }
//     .animate()
#endif
