#if canImport(UIKit)
import Foundation
import UIKit

public extension UICollectionViewLayout {
    
    func register<T: UICollectionReusableView>(decorationView: T.Type) {
        self.register(decorationView, forDecorationViewOfKind: decorationView.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(decorationNib: T.Type) {
        let uiNib = UINib(nibName: decorationNib.nibName, bundle: nil)
        self.register(uiNib, forDecorationViewOfKind: decorationNib.reuseIdentifier)
    }
    
}
#endif
