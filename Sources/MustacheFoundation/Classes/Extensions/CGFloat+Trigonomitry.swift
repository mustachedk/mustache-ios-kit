
import Foundation

#if canImport(UIKit)
import UIKit

extension CGFloat {
    
    public var toRadians: CGFloat {
        return self * .pi / 180
    }
    
    public var toDegrees: CGFloat {
        return self * 180 / .pi
    }
    
}

#endif
