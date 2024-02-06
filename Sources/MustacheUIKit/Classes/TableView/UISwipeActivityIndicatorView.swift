#if canImport(UIKit)
import Foundation
import UIKit

open class UISwipeActivityIndicatorView: UIActivityIndicatorView {

	var buttonLabel: UIView!

	init(buttonLabel: UIView){
        if #available(iOS 13.0, *) {
            super.init(style: UIActivityIndicatorView.Style.medium)
        } else {
            super.init(style: UIActivityIndicatorView.Style.white)
        }
		self.buttonLabel = buttonLabel
	}

	required public init(coder: NSCoder) {
		super.init(coder: coder)
	}

	override open func startAnimating() {
		super.startAnimating()
		self.buttonLabel.alpha = 0
	}

    override  open func stopAnimating() {
		super.stopAnimating()
		self.buttonLabel.alpha = 1
	}

}

extension UIView {

    func addActivityIndicatorView(color: UIColor = .white) -> UISwipeActivityIndicatorView? {

        if NSStringFromClass(type(of: self)) == "UISwipeActionStandardButton",
           let label = self.subviews.first(where: { NSStringFromClass(type(of: $0)) == "UIButtonLabel" }),
           let superview = label.superview {
            let activityIndicator = UISwipeActivityIndicatorView(buttonLabel: label)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = color
            superview.addSubviews(activityIndicator)
            
            activityIndicator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            return activityIndicator
        } else {
            return nil
        }
    }

}
#endif
