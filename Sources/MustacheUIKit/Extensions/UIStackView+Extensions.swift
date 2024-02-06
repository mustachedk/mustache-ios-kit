
#if canImport(UIKit)

import Foundation
import UIKit

public extension UIStackView {

    func clear() {
        self.arrangedSubviews.forEach({ $0.removeFromSuperview()} )
    }

}

#endif
