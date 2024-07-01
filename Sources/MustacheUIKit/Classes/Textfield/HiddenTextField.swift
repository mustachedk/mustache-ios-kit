#if canImport(UIKit)
import UIKit

open class HiddenTextField: UITextField {

    open override var placeholder: String? {
        get { return super.placeholder }
        set {
            if let placeholder = newValue {
                let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.clear]
                let attributedString = NSMutableAttributedString(string: placeholder, attributes: attributes)
                super.attributedPlaceholder = attributedString
            } else {
                super.placeholder = nil
                super.attributedPlaceholder = nil
            }
        }
    }

    open override var attributedPlaceholder: NSAttributedString? {
        get { return super.attributedPlaceholder }
        set {
            if let placeholder = newValue?.string {
                let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.clear]
                let attributedString = NSMutableAttributedString(string: placeholder, attributes: attributes)
                super.attributedPlaceholder = attributedString
            } else {
                super.placeholder = nil
                super.attributedPlaceholder = nil
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    fileprivate func configure() {
        self.tintColor = .clear

        guard let placeholder = self.placeholder else { return }

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        let attributedString = NSMutableAttributedString(string: placeholder, attributes: attributes)
        self.attributedPlaceholder = attributedString
    }

}
#endif
