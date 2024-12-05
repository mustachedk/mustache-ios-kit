#if canImport(UIKit)
import Foundation
import UIKit

public extension UIAlertController {
    
    static func alert(title: String? = nil, message: String? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return controller
    }
    
    static func sheet(title: String? = nil, message: String? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        return controller
    }
    
    func title(_ string: String) -> Self {
        self.title = string
        return self
    }
    
    func message(_ string: String) -> Self {
        self.message = string
        return self
    }
    
    func action(title: String, handler: ((String) -> Void)? = nil) -> Self {
        let action = UIAlertAction(title: title, style: .default) { [title] _ in
            handler?(title)
        }
        self.addAction(action)
        return self
    }
    
    func cancel(title: String, handler: ((String) -> Void)? = nil) -> Self {
        let action = UIAlertAction(title: title, style: .cancel) { [title] _ in
            handler?(title)
        }
        self.addAction(action)
        return self
    }
    
    func destructive(title: String, handler: ((String) -> Void)? = nil) -> Self {
        let action = UIAlertAction(title: title, style: .destructive) { [title] _ in
            handler?(title)
        }
        self.addAction(action)
        return self
    }
    
    @discardableResult
    func present(in viewController: UIViewController, animated: Bool = true, sourceView: UIView? = nil) -> Self {
        viewController.present(self, animated: animated)
        return self
    }
    
    
}
#endif
