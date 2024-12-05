import UIKit

public extension UIView {

    #if os(iOS)
    /**
     Convenience method for shake feedback on a view, useful for when the user has entered incorrect data

     - parameters:
     - completion: ((Bool) -> Void)?

     */
    func shake(completion: ((Bool) -> Void)? = nil) {

        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)

        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: { self.transform = CGAffineTransform.identity },
                       completion: completion)
    }
    #endif

    /**
     Convenience method for rotating a view using CGAffineTransform

     - parameters:
     - degrees: CGFloat

     */
    func rotate(degrees: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(rotationAngle: degrees * CGFloat(Double.pi / 180.0))
        }
    }

    /**
     Convenience method for changing the anchor point of a view

     - parameters:
     - anchor: CGPoint

     */
    func set(anchor: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * anchor.x, y: bounds.size.height * anchor.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchor
    }

}

public extension CAMediaTimingFunction {

    ///https://easings.net/#easeInSine
    static var easeInSine = CAMediaTimingFunction(controlPoints: 0.12, 0, 0.39, 0)

    ///https://easings.net/#easeOutSine
    static var easeOutSine = CAMediaTimingFunction(controlPoints: 0.61, 1, 0.88, 1)

    ///https://easings.net/#easeInOutSine
    static var easeInOutSine = CAMediaTimingFunction(controlPoints: 0.37, 0, 0.63, 1)

    ///https://easings.net/#easeInQuad
    static var easeInQuad = CAMediaTimingFunction(controlPoints: 0.11, 0, 0.5, 0)

    ///https://easings.net/#easeOutQuad
    static var easeOutQuad = CAMediaTimingFunction(controlPoints: 0.5, 1, 0.89, 1)

    ///https://easings.net/#easeInOutQuad
    static var easeInOutQuad = CAMediaTimingFunction(controlPoints: 0.45, 0, 0.55, 1)

    ///https://easings.net/#easeInCubic
    static var easeInCubic = CAMediaTimingFunction(controlPoints: 0.32, 0, 0.67, 0)

    ///https://easings.net/#easeOutCubic
    static var easeOutCubic = CAMediaTimingFunction(controlPoints: 0.33, 1, 0.68, 1)

    ///https://easings.net/#easeInOutCubic
    static var easeInOutCubic = CAMediaTimingFunction(controlPoints: 0.65, 0, 0.35, 1)

    ///https://easings.net/#easeInQuart
    static var easeInQuart = CAMediaTimingFunction(controlPoints: 0.5, 0, 0.75, 0)

    ///https://easings.net/#easeOutQuart
    static var easeOutQuart = CAMediaTimingFunction(controlPoints: 0.25, 1, 0.5, 1)

    ///https://easings.net/#easeInOutQuart
    static var easeInOutQuart = CAMediaTimingFunction(controlPoints: 0.76, 0, 0.24, 1)

    ///https://easings.net/#easeInQuint
    static var easeInQuint = CAMediaTimingFunction(controlPoints: 0.64, 0, 0.78, 0)

    ///https://easings.net/#easeOutQuint
    static var easeOutQuint = CAMediaTimingFunction(controlPoints: 0.22, 1, 0.36, 1)

    ///https://easings.net/#easeInOutQuint
    static var easeInOutQuint = CAMediaTimingFunction(controlPoints: 0.83, 0, 0.17, 1)

    ///https://easings.net/#easeInExpo
    static var easeInExpo = CAMediaTimingFunction(controlPoints: 0.7, 0, 0.84, 0)

    ///https://easings.net/#easeOutExpo
    static var easeOutExpo = CAMediaTimingFunction(controlPoints: 0.16, 1, 0.3, 1)

    ///https://easings.net/#easeInOutExpo
    static var easeInOutExpo = CAMediaTimingFunction(controlPoints: 0.87, 0, 0.13, 1)

    ///https://easings.net/#easeInCirc
    static var easeInCirc = CAMediaTimingFunction(controlPoints: 0.55, 0, 1, 0.45)

    ///https://easings.net/#easeOutCirc
    static var easeOutCirc = CAMediaTimingFunction(controlPoints: 0, 0.55, 0.45, 1)

    ///https://easings.net/#easeInOutCirc
    static var easeInOutCirc = CAMediaTimingFunction(controlPoints: 0.85, 0, 0.15, 1)

    ///https://easings.net/#easeInBack
    static var easeInBack = CAMediaTimingFunction(controlPoints: 0.36, 0, 0.66, -0.56)

    ///https://easings.net/#easeOutBack
    static var easeOutBack = CAMediaTimingFunction(controlPoints: 0.34, 1.56, 0.64, 1)

    ///https://easings.net/#easeInOutBack
    static var easeInOutBack = CAMediaTimingFunction(controlPoints: 0.68, -0.6, 0.32, 1.6)

}

public extension UIView {

    ///https://www.calayer.com/core-animation/2016/05/17/catransaction-in-depth.html
  class func animate(duration: TimeInterval, delay: TimeInterval = 0, animationOption: CAMediaTimingFunction, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {

         CATransaction.begin()
         CATransaction.setAnimationTimingFunction(animationOption)

         CATransaction.setCompletionBlock {
             completion?()
         }

         UIView.animate(withDuration: duration, delay: delay, animations: animations, completion: { _ in completion?() })


         CATransaction.commit()
     }

    func animateElastic(duration: TimeInterval, animationType: AnimationType, animationOption: ElasticAnimationType, isAdditive: Bool = false) {

        let animation = CAKeyframeAnimation(keyPath: animationType.rawValue)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.isAdditive = isAdditive

        switch animationOption {
            case .easeInElastic(let subType):
                animation.keyTimes = [0.0, 0.04, 0.08, 0.14, 0.18, 0.20, 0.26, 0.28, 0.40, 0.42, 0.56, 0.58, 0.72, 0.86, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0, 0, 0, 0, 0, 0.01, 0.01, -0.02, -0.02, 0.05, 0.04, -0.13, 0.37, 1]
                    case .oneToZero:
                        animation.values = [1, 1, 1, 1, 1, 1.01, 1.01, 0.98, 0.98, 1.05, 1.04, 0.87, 1.37, 0]
            }
            case .easeOutElastic(let subType):
                animation.keyTimes = [0.0, 0.16, 0.28, 0.44, 0.59, 0.73, 0.88, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0.0, 1.32, 0.87, 1.05, 0.98, 1.01, 1.0, 1.0]
                    case .oneToZero:
                        animation.values = [1.0, -0.32, 0.13, -0.05, 0.02, -0.01, 0.0, 0.0]
            }
            case .easeInOutElastic(let subType):
                animation.keyTimes = [0.0, 0.04, 0.08, 0.18, 0.20, 0.28, 0.30, 0.38, 0.40, 0.60, 0.62, 0.70, 0.72, 0.80, 0.82, 0.90, 0.92, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0.0, 0.0, 0.0, -0.01, 0.0, 0.02, 0.02, -0.09, 0.12, 1.12, 1.09, 0.98, 0.98, 1.0, 1.01, 1.0, 1.0, 1.0]
                    case .oneToZero:
                        animation.values = [1.0, 1.0, 1.0, 1.01, 1.0, 0.98, 0.98, 1.09, 1.12, -0.12, -0.09, 0.02, 0.02, 0, -0.01, 0.0, 0.0, 0.0]
            }
            case .easeInBounce(let subType):
                animation.keyTimes = [0.0, 0.04, 0.08, 0.18, 0.26, 0.46, 0.64, 0.76, 0.88, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0.0, 0.02, 0.01, 0.06, 0.02, 0.25, 0.02, 0.56, 0.89, 1.0]
                    case .oneToZero:
                        animation.values = [1.0, 0.98, 0.99, 0.94, 0.98, 0.75, 0.98, 0.44, 0.11, 0.0]
            }
            case .easeOutBounce(let subType):
                animation.keyTimes = [0.0, 0.12, 0.24, 0.36, 0.54, 0.74, 0.82, 0.92, 0.96, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0.0, 0.11, 0.44, 0.98, 0.75, 0.98, 0.94, 0.99, 0.98, 1.1]
                    case .oneToZero:
                        animation.values = [1.0, 0.89, 0.56, 0.02, 0.25, 0.02, 0.06, 0.01, 0.02, 0.0]
            }
            case .easeInOutBounce(let subType):
                animation.keyTimes = [0.0, 0.02, 0.04, 0.10, 0.14, 0.22, 0.32, 0.42, 0.50, 0.58, 0.68, 0.78, 0.86, 0.90, 0.96, 0.98, 1.0]
                switch subType {
                    case .zeroToOne:
                        animation.values = [0.0, 0.01, 0.0, 0.03, 0.01, 0.12, 0.01, 0.40, 0.50, 0.60, 0.99, 0.88, 0.99, 0.97, 1.0, 0.99, 1.0]
                    case .oneToZero:
                        animation.values = [1.0, 0.99, 1.0, 0.97, 0.99, 0.88, 0.99, 0.60, 0.50, 0.40, 0.01, 0.12, 0.01, 0.03, 0.0, 0.01, 0.0]
            }
        }

        self.layer.add(animation, forKey: nil)
    }
}

public enum AnimationType: String {
    case opacity = "opacity"
    case backgroundColor = "backgroundColor"
    case position = "position"
    case positionX = "position.x"
    case positionY = "position.y"
    case scale = "transform.scale"
    case scaleX = "transform.scale.x"
    case scalyY = "transform.scale.y"
}

public enum ElasticAnimationType {
    ///https://easings.net/#easeInElastic
    case easeInElastic(ElasticAnimationSubType)

    ///https://easings.net/#easeOutElastic
    case easeOutElastic(ElasticAnimationSubType)

    ///https://easings.net/#easeInOutElastic
    case easeInOutElastic(ElasticAnimationSubType)

    ///https://easings.net/#easeInBounce
    case easeInBounce(ElasticAnimationSubType)

    ///https://easings.net/#easeOutBounce
    case easeOutBounce(ElasticAnimationSubType)

    ///https://easings.net/#easeInOutBounce
    case easeInOutBounce(ElasticAnimationSubType)
}

public enum ElasticAnimationSubType {
    case zeroToOne
    case oneToZero
}
