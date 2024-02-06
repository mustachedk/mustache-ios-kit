#if canImport(UIKit)
import Foundation
import UIKit

extension UIButton {
    
    public func setTitle(_ title: String?){
        for state: UIControl.State in [.normal, .highlighted, .disabled, .selected] {
            self.setTitle(title, for: state)
        }
    }
    
    public func setTitleColor(_ color: UIColor?){
        for state: UIControl.State in [.normal, .highlighted, .disabled, .selected] {
            self.setTitleColor(color, for: state)
        }
    }
}
#endif
