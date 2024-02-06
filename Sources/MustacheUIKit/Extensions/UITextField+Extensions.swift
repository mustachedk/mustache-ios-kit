#if canImport(UIKit)

import UIKit

public extension UITextField {

    /// The text of the UITextField or an empty text
    var safeText: String { return self.text ?? "" }

    /**
    Adds a toolbar to the UITextField

    - returns:
    UIToolbar

    - parameters:
        - handlePrevious: () -> Void
        - handleNext: () -> Void
        - handleDone: () -> Void
        - handleDismiss: () -> Void

    */

}

public extension UITextField {

    func modifyClearButtonWith(image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.frame = CGRect(x: self.frame.width - 18, y: (self.frame.height - 18) / 2, width: 18, height: 18)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }

    @objc
    func clear(sender : AnyObject) {
        self.text = nil
        self.sendActions(for: .valueChanged)
        self.resignFirstResponder()
    }
}

#endif
