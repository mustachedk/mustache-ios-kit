
#if canImport(UIKit)

import Combine
import Foundation
import UIKit

@available(iOS 13.0, macOS 15, *)
public extension UITextField {
    
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text  ?? "" }
            .eraseToAnyPublisher()
    }
}
#endif
