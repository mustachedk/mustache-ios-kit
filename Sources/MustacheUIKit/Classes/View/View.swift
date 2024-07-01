#if canImport(UIKit)
import UIKit

@IBDesignable
open class MView: UIView {

    // ----------------------------- Color -----------------------------//

    @IBInspectable
    public var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    @IBInspectable
    public var borderColor: UIColor? {
        get { return UIColor(cgColor: self.layer.borderColor!) }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    // ----------------------------- Rounded -----------------------------//

    @IBInspectable
    open var cornerRadius: CGFloat {
        set { self.layer.cornerRadius = newValue }
        get { return self.layer.cornerRadius }
    }

    fileprivate func configureRadius() {
        // self.clipsToBounds = self.layer.cornerRadius > 0
    }
    
    @IBInspectable
    open var cornerUL: Bool = false { //UpperLeft
        didSet { self.updateCorners() }
    }

    @IBInspectable
    open var cornerUR: Bool = false { //UpperRight
        didSet { self.updateCorners() }
    }

    @IBInspectable
    open var cornerLL: Bool = false { //LowerLeft
        didSet { self.updateCorners() }
    }

    @IBInspectable
    open var cornerLR: Bool = false { //LowerRight
        didSet { self.updateCorners() }
    }

    fileprivate func updateCorners() {
        var corners: CACornerMask = CACornerMask(rawValue: 0)
        if self.cornerUL { corners.insert(.layerMinXMinYCorner) }
        if self.cornerUR { corners.insert(.layerMaxXMinYCorner) }
        if self.cornerLL { corners.insert(.layerMinXMaxYCorner) }
        if self.cornerLR { corners.insert(.layerMaxXMaxYCorner) }
        self.layer.maskedCorners = corners
    }

    // ----------------------------- Shadow -----------------------------//

    @IBInspectable
    open var hasShadow: Bool = false

    @IBInspectable
    open var sketchColor: UIColor = .black

    @IBInspectable
    open var sketchAlpha: Float = 0.5

    @IBInspectable
    open var sketchX: CGFloat = 0

    @IBInspectable
    open var sketchY: CGFloat = 0

    @IBInspectable
    open var sketchBlur: CGFloat = 0

    @IBInspectable
    open var sketchSpread: CGFloat = 0

    fileprivate func configureShadow() {

        if !self.hasShadow { return }

        self.layer.shadowColor = self.sketchColor.cgColor
        self.layer.shadowOpacity = self.sketchAlpha
        self.layer.shadowOffset = CGSize(width: self.sketchX, height: self.sketchY)
        self.layer.shadowRadius = self.sketchBlur / 2.0
        if self.sketchSpread == 0 {
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        } else {
            let dx = -self.sketchSpread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            self.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: self.layer.cornerRadius).cgPath
        }

    }

    // ----------------------------------------------------------//

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.configureRadius()
        self.configureShadow()
    }
}
#endif
