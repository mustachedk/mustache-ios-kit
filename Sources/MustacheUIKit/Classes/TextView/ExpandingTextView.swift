#if canImport(UIKit)
import UIKit

open class ExpandingTextView: UITextView {

    // limit the height of expansion per intrinsicContentSize
    @IBInspectable
    open var maxHeight: CGFloat = 0.0

    override public init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }

    override open var text: String! {
        didSet { invalidateIntrinsicContentSize() }
    }

    override open var font: UIFont? {
        didSet { invalidateIntrinsicContentSize() }
    }

    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        if size.height == UIView.noIntrinsicMetric {
            // force layout
            layoutManager.glyphRange(for: textContainer)
            size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
        }

        if maxHeight > 0.0 && size.height > maxHeight {
            size.height = maxHeight
            if !isScrollEnabled { isScrollEnabled = true }
        } else if isScrollEnabled {
            isScrollEnabled = false
        }

        return size
    }

    @objc private func textDidChange(_ note: Notification) {
        // needed incase isScrollEnabled is set to true which stops automatically calling invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }

}
#endif
