#if canImport(UIKit)
import Foundation
import UIKit

@IBDesignable
public class HighlightSiblingsButton: UIButton {
    
    @IBOutlet public var siblings: [UIView]!
    
    override public var isHighlighted: Bool {
        didSet { self.isHighlighted ? self.tintSiblings() : self.removeTintSiblings() }
    }
    
    public func tintSiblings() {
        UIView.animate(withDuration: 0.1) {
            self.siblings.forEach { $0.alpha = 0.5 }
        }
    }
    
    public func removeTintSiblings() {
        UIView.animate(withDuration: 0.1) {
            self.siblings.forEach { $0.alpha = 1.0 }
        }
    }
    
}
#endif
