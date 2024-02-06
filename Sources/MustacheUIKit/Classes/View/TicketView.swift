#if canImport(UIKit)
import Foundation
import UIKit
import MustacheFoundation

@IBDesignable
public class TicketView: UIView {

    // ----------------------------- Punch -----------------------------//

    public var punchPositions: [UIRectEdge] = []

    fileprivate let punchRadius: CGFloat = 10

    @IBInspectable public var punchLeft: Bool = false {
        didSet {
            if self.punchLeft {
                var unique = Set(self.punchPositions)
                unique.insert(.left)
                self.punchPositions = Array(unique)
            } else {
                var unique = Set(self.punchPositions)
                unique.remove(.left)
                self.punchPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var punchTop: Bool = false {
        didSet {
            if self.punchTop {
                var unique = Set(self.punchPositions)
                unique.insert(.top)
                self.punchPositions = Array(unique)
            } else {
                var unique = Set(self.punchPositions)
                unique.remove(.top)
                self.punchPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var punchRight: Bool = false {
        didSet {
            if self.punchRight {
                var unique = Set(self.punchPositions)
                unique.insert(.right)
                self.punchPositions = Array(unique)
            } else {
                var unique = Set(self.punchPositions)
                unique.remove(.right)
                self.punchPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var punchBottom: Bool = false {
        didSet {
            if self.punchBottom {
                var unique = Set(self.punchPositions)
                unique.insert(.bottom)
                self.punchPositions = Array(unique)
            } else {
                var unique = Set(self.punchPositions)
                unique.remove(.bottom)
                self.punchPositions = Array(unique)
            }
        }
    }

    // ----------------------------- Rip -----------------------------//

    public var ripPositions: [UIRectEdge] = []

    fileprivate let ripRadius: CGFloat = 2.5

    fileprivate var ripSpacing: CGFloat { return self.ripRadius * 2 }

    fileprivate var ripOffset: CGFloat { return self.ripRadius / 2.5 }

    @IBInspectable public var ripLeft: Bool = false {
        didSet {
            if self.ripLeft {
                var unique = Set(self.ripPositions)
                unique.insert(.left)
                self.ripPositions = Array(unique)
            } else {
                var unique = Set(self.ripPositions)
                unique.remove(.left)
                self.ripPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var ripTop: Bool = false {
        didSet {
            if self.ripTop {
                var unique = Set(self.ripPositions)
                unique.insert(.top)
                self.ripPositions = Array(unique)
            } else {
                var unique = Set(self.ripPositions)
                unique.remove(.top)
                self.ripPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var ripRight: Bool = false {
        didSet {
            if self.ripRight {
                var unique = Set(self.ripPositions)
                unique.insert(.right)
                self.ripPositions = Array(unique)
            } else {
                var unique = Set(self.ripPositions)
                unique.remove(.right)
                self.ripPositions = Array(unique)
            }
        }
    }

    @IBInspectable public var ripBottom: Bool = false {
        didSet {
            if self.ripBottom {
                var unique = Set(self.ripPositions)
                unique.insert(.bottom)
                self.ripPositions = Array(unique)
            } else {
                var unique = Set(self.ripPositions)
                unique.remove(.bottom)
                self.ripPositions = Array(unique)
            }
        }
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

    fileprivate var shadowLayer = CAShapeLayer()

    fileprivate func configureShadow() {

        if !self.hasShadow || self.maskPath == nil { return }

        self.shadowLayer.isHidden = self.isHidden

        self.shadowLayer.frame = self.frame
        self.shadowLayer.backgroundColor = UIColor.clear.cgColor

        self.shadowLayer.shadowPath = self.maskPath.cgPath
        self.shadowLayer.shadowColor = self.sketchColor.cgColor
        self.shadowLayer.shadowOpacity = self.sketchAlpha
        self.shadowLayer.shadowOffset = CGSize(width: self.sketchX, height: self.sketchY)
        self.shadowLayer.shadowRadius = self.sketchBlur / 2.0

        self.superview?.layer.insertSublayer(self.shadowLayer, below: self.layer)

    }

    // ----------------------------- Radius -----------------------------//

    @IBInspectable
    open var cornerRadius: CGFloat {
        set { self.layer.cornerRadius = newValue }
        get { return self.layer.cornerRadius }
    }

    fileprivate func configureRadius() {
        self.clipsToBounds = self.cornerRadius > 0 && !self.hasShadow
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

    // ----------------------------- Lifecycle -----------------------------//
    public override var frame: CGRect {
        didSet { self.configureShadow() }
    }

    public override var bounds: CGRect {
        didSet { self.configureShadow() }
    }

    public override var center: CGPoint {
        didSet { self.configureShadow() }
    }
    public override var isHidden: Bool {
        didSet { self.configureShadow() }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.configureRipAndPunch()
        self.configureShadow()
        self.configureRadius()

    }

    // https://www.raywenderlich.com/411-core-graphics-tutorial-part-1-getting-started
    // https://www.studieportalen.dk/forums/thread.aspx?id=1892743
    // https://www.regneregler.dk/retvinklet-trekant
    // TicketView.JPG

    fileprivate var maskPath: UIBezierPath!

    fileprivate func configureRipAndPunch() {

        let centerX = self.bounds.width / 2
        let centerY = self.bounds.height / 2

        let right = self.bounds.width
        let bottom = self.bounds.height

        self.maskPath = UIBezierPath(rect: self.bounds)
        self.maskPath.move(to: .zero)

        let singleRipLength: CGFloat = (2.0 * self.ripRadius) + self.ripSpacing

        let offset: CGFloat = self.ripRadius - sqrtf(pow(self.ripRadius.float, 2.0) - pow(self.ripOffset.float, 2.0)).cgfloat
        let offsetAngle: CGFloat = asin(self.ripOffset / self.ripRadius).toDegrees()

        let horizontalAvailableSpace: CGFloat = self.bounds.width - self.ripSpacing
        let horizontalNumberOfRips: Int = Int(horizontalAvailableSpace / singleRipLength)
        let horizontalRemainder: CGFloat = horizontalAvailableSpace - (horizontalNumberOfRips.cgfloat * singleRipLength)

        let verticalAvailableSpace: CGFloat = self.bounds.height - self.ripSpacing
        let verticalNumberOfRips: Int = Int(verticalAvailableSpace / singleRipLength)
        let verticalRemainder: CGFloat = verticalAvailableSpace - (verticalNumberOfRips.cgfloat * singleRipLength)

        // -------------------------------------------------------- Top -------------------------------------------------------- //

        if self.punchPositions.contains(.top) && !self.ripPositions.contains(.top) {

            self.maskPath.move(to: CGPoint(x: centerX - self.punchRadius, y: 0))
            self.maskPath.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: punchRadius, startAngle: 180.cgfloat.toRadians(), endAngle: 0.cgfloat.toRadians(), clockwise: false)

        } else if !self.punchPositions.contains(.top) && self.ripPositions.contains(.top) {

            var x: CGFloat = ripSpacing + (horizontalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: x + offset, y: 0))
            for _ in 0..<horizontalNumberOfRips {

                self.maskPath.addArc(withCenter: CGPoint(x: x + self.ripRadius, y: self.ripOffset), radius: self.ripRadius, startAngle: (180.0 + offsetAngle).toRadians(), endAngle: (360 - offsetAngle).toRadians(), clockwise: false)
                x += singleRipLength
                self.maskPath.move(to: CGPoint(x: x, y: 0))
            }

        } else if self.punchPositions.contains(.top) && self.ripPositions.contains(.top) {

            let punchRect = CGRect(x: centerX - self.punchRadius, y: -self.punchRadius, width: 2 * self.punchRadius, height: 2 * self.punchRadius).insetBy(dx: (self.punchRadius + self.ripRadius) / -2, dy: 0)
            var punchDrawed: Bool = false

            var x: CGFloat = ripSpacing + (horizontalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: x + offset, y: 0))

            for _ in 0..<horizontalNumberOfRips {

                let ripRect = CGRect(x: x, y: -self.ripRadius, width: 2 * self.ripRadius, height: 2 * self.ripRadius)
                if punchRect.intersects(ripRect) && !punchDrawed {

                    self.maskPath.move(to: CGPoint(x: centerX - self.punchRadius, y: 0))
                    self.maskPath.addArc(withCenter: CGPoint(x: centerX, y: 0), radius: punchRadius, startAngle: 180.cgfloat.toRadians(), endAngle: 0.cgfloat.toRadians(), clockwise: false)
                    punchDrawed = true

                } else if !punchRect.intersects(ripRect) {
                    self.maskPath.addArc(withCenter: CGPoint(x: x + self.ripRadius, y: self.ripOffset), radius: self.ripRadius, startAngle: (180.0 + offsetAngle).toRadians(), endAngle: (360 - offsetAngle).toRadians(), clockwise: false)

                }
                x += singleRipLength
                self.maskPath.move(to: CGPoint(x: x, y: 0))
            }

        }

        self.maskPath.move(to: CGPoint(x: right, y: 0))

        // -------------------------------------------------------- Right -------------------------------------------------------- //

        if self.punchPositions.contains(.right) && !self.ripPositions.contains(.right) {

            self.maskPath.move(to: CGPoint(x: right, y: centerY - punchRadius))
            self.maskPath.addArc(withCenter: CGPoint(x: right, y: centerY), radius: punchRadius, startAngle: 270.cgfloat.toRadians(), endAngle: 90.cgfloat.toRadians(), clockwise: false)
            self.maskPath.move(to: CGPoint(x: right, y: bottom))

        } else if !self.punchPositions.contains(.right) && self.ripPositions.contains(.right) {

            var y: CGFloat = ripSpacing + (verticalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: right, y: y + offset))
            for _ in 0..<verticalNumberOfRips {

                self.maskPath.addArc(withCenter: CGPoint(x: right - self.ripOffset, y: y + self.ripRadius), radius: self.ripRadius, startAngle: (270.0 + offsetAngle).toRadians(), endAngle: (90 - offsetAngle).toRadians(), clockwise: false)
                y += singleRipLength
                self.maskPath.move(to: CGPoint(x: right, y: y))
            }

        } else if self.punchPositions.contains(.right) && self.ripPositions.contains(.right) {

            let punchRect = CGRect(x: right - self.punchRadius, y: centerY - self.punchRadius, width: 2 * self.punchRadius, height: 2 * self.punchRadius).insetBy(dx: 0, dy: (self.punchRadius + self.ripRadius) / -2)
            var punchDrawed: Bool = false

            var y: CGFloat = ripSpacing + (verticalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: right, y: y + offset))

            for _ in 0..<verticalNumberOfRips {

                let ripRect = CGRect(x: right - self.ripRadius, y: y, width: 2 * self.ripRadius, height: 2 * self.ripRadius)
                if punchRect.intersects(ripRect) && !punchDrawed {

                    self.maskPath.move(to: CGPoint(x: right, y: centerY - self.punchRadius))
                    self.maskPath.addArc(withCenter: CGPoint(x: right, y: centerY), radius: punchRadius, startAngle: 270.cgfloat.toRadians(), endAngle: 90.cgfloat.toRadians(), clockwise: false)
                    punchDrawed = true

                } else if !punchRect.intersects(ripRect) {
                    self.maskPath.addArc(withCenter: CGPoint(x: right - self.ripOffset, y: y + self.ripRadius), radius: self.ripRadius, startAngle: (270.0 + offsetAngle).toRadians(), endAngle: (90 - offsetAngle).toRadians(), clockwise: false)

                }
                y += singleRipLength
                self.maskPath.move(to: CGPoint(x: right, y: y))
            }

        }

        self.maskPath.move(to: CGPoint(x: right, y: bottom))

        // -------------------------------------------------------- Bottom -------------------------------------------------------- //

        if self.punchPositions.contains(.bottom) && !self.ripPositions.contains(.bottom) {

            self.maskPath.move(to: CGPoint(x: centerX + punchRadius, y: bottom))
            self.maskPath.addArc(withCenter: CGPoint(x: centerX, y: bottom), radius: punchRadius, startAngle: 0.cgfloat.toRadians(), endAngle: 180.cgfloat.toRadians(), clockwise: false)

        } else if !self.punchPositions.contains(.bottom) && self.ripPositions.contains(.bottom) {

            var x: CGFloat = right - ripSpacing - (horizontalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: x - offset, y: bottom))

            for _ in 0..<horizontalNumberOfRips {

                self.maskPath.addArc(withCenter: CGPoint(x: x - self.ripRadius, y: bottom - self.ripOffset), radius: self.ripRadius, startAngle: (0 + offsetAngle).toRadians(), endAngle: (180 - offsetAngle).toRadians(), clockwise: false)
                x -= singleRipLength
                self.maskPath.move(to: CGPoint(x: x, y: bottom))
            }

        } else if self.punchPositions.contains(.bottom) && self.ripPositions.contains(.bottom) {

            let punchRect = CGRect(x: centerX - self.punchRadius, y: -self.punchRadius, width: 2 * self.punchRadius, height: 2 * self.punchRadius).insetBy(dx: (self.punchRadius + self.ripRadius) / -2, dy: 0)
            var punchDrawed: Bool = false

            var x: CGFloat = right - ripSpacing - (horizontalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: x - offset, y: bottom))

            for _ in 0..<horizontalNumberOfRips {

                let ripRect = CGRect(x: x - 2 * self.ripRadius, y: -self.ripRadius, width: 2 * self.ripRadius, height: 2 * self.ripRadius)
                if punchRect.intersects(ripRect) && !punchDrawed {

                    self.maskPath.move(to: CGPoint(x: centerX + punchRadius, y: bottom))
                    self.maskPath.addArc(withCenter: CGPoint(x: centerX, y: bottom), radius: punchRadius, startAngle: 0.cgfloat.toRadians(), endAngle: 180.cgfloat.toRadians(), clockwise: false)
                    punchDrawed = true

                } else if !punchRect.intersects(ripRect) {
                    self.maskPath.addArc(withCenter: CGPoint(x: x - self.ripRadius, y: bottom - self.ripOffset), radius: self.ripRadius, startAngle: (0 + offsetAngle).toRadians(), endAngle: (180 - offsetAngle).toRadians(), clockwise: false)

                }

                x -= singleRipLength
                self.maskPath.move(to: CGPoint(x: x, y: bottom))
            }

        }

        self.maskPath.move(to: CGPoint(x: 0, y: bottom))

        // -------------------------------------------------------- Left -------------------------------------------------------- //

        if self.punchPositions.contains(.left) && !self.ripPositions.contains(.left) {

            self.maskPath.move(to: CGPoint(x: 0, y: centerY + punchRadius))
            self.maskPath.addArc(withCenter: CGPoint(x: 0, y: centerY), radius: punchRadius, startAngle: 90.cgfloat.toRadians(), endAngle: 270.cgfloat.toRadians(), clockwise: false)

        } else if !self.punchPositions.contains(.left) && self.ripPositions.contains(.left) {

            var y: CGFloat = bottom - ripSpacing - (verticalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: 0, y: y - offset))
            for _ in 0..<verticalNumberOfRips {

                self.maskPath.addArc(withCenter: CGPoint(x: self.ripOffset, y: y - self.ripRadius), radius: self.ripRadius, startAngle: (90.0 + offsetAngle).toRadians(), endAngle: (270 - offsetAngle).toRadians(), clockwise: false)
                y -= singleRipLength
                self.maskPath.move(to: CGPoint(x: 0, y: y))
            }

        } else if self.punchPositions.contains(.left) && self.ripPositions.contains(.left) {

            let punchRect = CGRect(x: 0 - self.punchRadius, y: centerY - self.punchRadius, width: 2 * self.punchRadius, height: 2 * self.punchRadius).insetBy(dx: 0, dy: (self.punchRadius + self.ripRadius) / -2)
            var punchDrawed: Bool = false

            var y: CGFloat = bottom - ripSpacing - (verticalRemainder / 2)

            self.maskPath.move(to: CGPoint(x: 0, y: y - offset))

            for _ in 0..<verticalNumberOfRips {

                let ripRect = CGRect(x: -self.ripRadius, y: y - 2 * self.ripRadius, width: 2 * self.ripRadius, height: 2 * self.ripRadius)
                if punchRect.intersects(ripRect) && !punchDrawed {

                    self.maskPath.move(to: CGPoint(x: 0, y: centerY + punchRadius))
                    self.maskPath.addArc(withCenter: CGPoint(x: 0, y: centerY), radius: punchRadius, startAngle: 90.cgfloat.toRadians(), endAngle: 270.cgfloat.toRadians(), clockwise: false)
                    punchDrawed = true

                } else if !punchRect.intersects(ripRect) {
                    self.maskPath.addArc(withCenter: CGPoint(x: self.ripOffset, y: y - self.ripRadius), radius: self.ripRadius, startAngle: (90.0 + offsetAngle).toRadians(), endAngle: (270 - offsetAngle).toRadians(), clockwise: false)

                }
                y -= singleRipLength
                self.maskPath.move(to: CGPoint(x: 0, y: y))
            }
        }

        self.maskPath.move(to: .zero)

        // -------------------------------------------------------- Apply-------------------------------------------------------- //

        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = self.maskPath.cgPath

        self.layer.mask = maskLayer
    }
}

extension UIRectEdge: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(self.rawValue) }
}
#endif
