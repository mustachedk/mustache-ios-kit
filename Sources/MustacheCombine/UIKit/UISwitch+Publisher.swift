
import Foundation
import UIKit
import Combine

@available(iOS 13.0, *)
public extension UISwitch {
    
    func isOnPublisher() -> AnyPublisher<Bool, Never> {
        self.publisher(for: .valueChanged)
            .map{ $0.isOn }
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
}
