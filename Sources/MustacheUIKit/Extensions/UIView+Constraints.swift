
import Foundation
import UIKit

extension UIView {
    
    func constraint(to view: UIView, constant: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: constant).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: constant).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
        
    }
    
}
