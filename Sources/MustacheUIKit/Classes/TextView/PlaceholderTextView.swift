
#if canImport(UIKit)

import UIKit

@IBDesignable
open class PlaceholderTextView: UITextView {

    private struct Constants {
        static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }

    public let placeholderLabel: UILabel = UILabel()

    private var placeholderLabelConstraints = [NSLayoutConstraint]()

    @IBInspectable open var placeholder: String? {
        didSet {
            self.placeholderLabel.text = self.placeholder
        }
    }

    @IBInspectable open var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.placeholderLabel.attributedText = self.attributedPlaceholder
        }
    }

    @IBInspectable open var placeholderColor: UIColor = PlaceholderTextView.Constants.defaultiOSPlaceholderColor {
        didSet {
            self.placeholderLabel.textColor = self.placeholderColor
        }
    }

    override open var font: UIFont! {
        didSet {
            if self.placeholderFont == nil {
                self.placeholderLabel.font = font
            }
        }
    }

    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? self.placeholderFont : self.font
            self.placeholderLabel.font = font
        }
    }

    override open var textAlignment: NSTextAlignment {
        didSet {
            self.placeholderLabel.textAlignment = self.textAlignment
        }
    }

    override open var text: String! {
        didSet {
            self.textDidChange()
        }
    }

    override open var attributedText: NSAttributedString! {
        didSet {
            self.textDidChange()
        }
    }

    override open var textContainerInset: UIEdgeInsets {
        didSet {
            self.updateConstraintsForPlaceholderLabel()
        }
    }

    override public init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)

        self.placeholderLabel.font = font
        self.placeholderLabel.textColor = placeholderColor
        self.placeholderLabel.textAlignment = textAlignment
        self.placeholderLabel.text = placeholder
        self.placeholderLabel.numberOfLines = 0
        self.placeholderLabel.backgroundColor = UIColor.clear
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(placeholderLabel)
        self.updateConstraintsForPlaceholderLabel()
    }

    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
                                                            options: [],
                                                            metrics: nil,
                                                            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
                item: placeholderLabel,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1.0,
                constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
        ))
        self.removeConstraints(placeholderLabelConstraints)
        self.addConstraints(newConstraints)
        self.placeholderLabelConstraints = newConstraints
    }

    @objc private func textDidChange() {
        self.placeholderLabel.isHidden = !text.isEmpty
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }

}
#endif
