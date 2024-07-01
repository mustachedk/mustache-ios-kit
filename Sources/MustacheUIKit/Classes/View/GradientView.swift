#if canImport(UIKit)
import UIKit

@IBDesignable
open class GradientView: UIView {

    @IBInspectable open var type: UInt = 0 {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable open var startColor: UIColor = UIColor.white {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable open var endColor: UIColor = UIColor.black {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable open var startPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable open var endPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { self.setNeedsLayout() }
    }

    override class open var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override open func layoutSubviews() {
        self.backgroundColor = .clear
        (layer as! CAGradientLayer).colors = [startColor.cgColor, endColor.cgColor]
        (layer as! CAGradientLayer).startPoint = startPoint
        (layer as! CAGradientLayer).endPoint = endPoint
        (layer as! CAGradientLayer).type = GradientViewType(rawValue: self.type)?.layerType ?? .axial
    }
}

enum GradientViewType: UInt {

    case axial = 0
    case radial = 1
    @available(iOS 12.0, *) case conic = 2

    var layerType: CAGradientLayerType {
        switch self {
            case .axial:
                return .axial
            case .radial:
                return .radial
            case .conic:
                if #available(iOS 12, *) {
                    return .conic
                } else {
                    return .radial
                }

        }
    }
}
#endif
