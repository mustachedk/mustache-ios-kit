import UIKit

@IBDesignable
open class Button: UIButton {
    
    //----------------------------------- Siblings -----------------------------------//
    
    @IBOutlet public var siblings: [UIView]!
    
    open override var isHighlighted: Bool {
        didSet { self.isHighlighted ? self.tintSiblings() : self.removeTintSiblings() }
    }
    
    func tintSiblings() {
        UIView.animate(withDuration: 0.1) {
            self.siblings?.forEach { $0.alpha = 0.5 }
        }
    }
    
    func removeTintSiblings() {
        UIView.animate(withDuration: 0.1) {
            self.siblings?.forEach { $0.alpha = 1.0 }
        }
    }
    
    //----------------------------------- UIActivityIndicator -----------------------------------//

    /// Border with on the layer
    @IBInspectable
    public var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    /// Border color on the layer
    @IBInspectable
    public var borderColor: UIColor? {
        get { return UIColor(cgColor: self.layer.borderColor!) }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    //----------------------------------- IsBusy -----------------------------------//

    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        } else {
            return UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        }
    }()

    /// ActivityIndicatorStyle for the button when its busy
    public var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get { return self.activityIndicator.style }
        set { self.activityIndicator.style = newValue }
    }
    
    /// Hides the text and shows an UIActivityIndicatorView spinning when true
    open var isBusy: Bool = false {
        didSet {
            self.isUserInteractionEnabled = !isBusy
            
            self.activityIndicator.color = self.titleLabel?.textColor ?? self.tintColor
            self.isBusy ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            
            self.titleLabel?.layer.opacity = self.isBusy ? 0 : 1
            self.imageView?.layer.opacity = self.isBusy ? 0 : 1
            
            self.bringSubviewToFront(self.activityIndicator)
            
        }
    }

    //----------------------------------- init -----------------------------------//

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    fileprivate func configureView() {
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false

        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.activityIndicator)
        self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    // ----------------------------- Rounded -----------------------------//

    /// Corner radius with on the layer
    @IBInspectable
    open var cornerRadius: CGFloat {
        set { self.layer.cornerRadius = newValue }
        get { return self.layer.cornerRadius }
    }

    fileprivate func configureRadius() {
        // self.clipsToBounds = self.layer.cornerRadius > 0
    }

    /// Should the upper left corner be rounded
    @IBInspectable
    open var cornerUL: Bool = false { //UpperLeft
        didSet { self.updateCorners() }
    }

    /// Should the upper right corner be rounded
    @IBInspectable
    open var cornerUR: Bool = false { //UpperRight
        didSet { self.updateCorners() }
    }

    /// Should the lower left corner be rounded
    @IBInspectable
    open var cornerLL: Bool = false { //LowerLeft
        didSet { self.updateCorners() }
    }

    /// Should the lower right corner be rounded
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


    /// Applies shadow the view
    @IBInspectable
    open var hasShadow: Bool = false

    /// Color of shadow, default .black
    @IBInspectable
    open var sketchColor: UIColor = .black

    /// Alpha of shadow as defined in Sketch
    @IBInspectable
    open var sketchAlpha: Float = 0.5

    /// X of shadow as defined in Sketch
    @IBInspectable
    open var sketchX: CGFloat = 0

    /// Y of shadow as defined in Sketch
    @IBInspectable
    open var sketchY: CGFloat = 0

    /// Blur of shadow as defined in Sketch
    @IBInspectable
    open var sketchBlur: CGFloat = 0

    /// Spread of shadow as defined in Sketch
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

    // ----------------------------- LifeCycle -----------------------------//

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.configureRadius()
        self.configureShadow()
    }

}
