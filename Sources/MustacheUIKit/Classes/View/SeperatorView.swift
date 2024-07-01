#if canImport(UIKit)
import Foundation
import UIKit

@available(iOS 13.0, macOS 15, *)
@IBDesignable
class SeperatorView: UIView {
    
    @IBInspectable
    var separatorColor: UIColor = UIColor.separator {
        didSet {
            self.backgroundColor = self.separatorColor
        }
    }
    
    @IBInspectable
    var isHorizontal: Bool = true {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        
        let lineHeight = 1.0 / UIScreen.main.scale
        
        if self.isHorizontal {
            intrinsicContentSize.height = lineHeight
        } else {
            intrinsicContentSize.width = lineHeight
        }
        
        return intrinsicContentSize
    }
    
}
#endif
