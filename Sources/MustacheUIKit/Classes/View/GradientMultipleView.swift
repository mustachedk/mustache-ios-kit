#if canImport(UIKit)
import Foundation
import UIKit

open class GradientMultipleView: UIView {

    open var startPoint: CGPoint = .init(x: 0, y: 0) {
        didSet {
            (self.layer as! CAGradientLayer).startPoint = self.startPoint
        }
    }

    open var endPoint: CGPoint = .init(x: 0, y: 1) {
        didSet {
            (self.layer as! CAGradientLayer).endPoint = self.endPoint
        }
    }

    open var colors: [UIColor] = [.clear, .clear] {
        didSet {
            (self.layer as! CAGradientLayer).colors = self.colors.map(\.cgColor)
        }
    }

    open var locations: [Double] = [0, 1] {
        didSet {
            (self.layer as! CAGradientLayer).locations = self.locations.map(\.number)
        }
    }

    override class open var layerClass: AnyClass { return CAGradientLayer.self }


}
#endif
