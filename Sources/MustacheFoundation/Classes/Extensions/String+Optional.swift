
import Foundation

public extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
            case .some(let wrapped): return wrapped.isEmpty
            case .none: return true
        }
    }
    
    var orEmpty: String {
        switch self {
            case .some(let wrapped): return wrapped
            case .none: return ""
        }
    }
    
}
