
import Foundation

public extension Optional {

    var exists: Bool {
        switch self {
            case .none: return false
            case .some(_):return true
        }
    }
    
    var isNil: Bool {
        return !self.exists
    }
    
}
