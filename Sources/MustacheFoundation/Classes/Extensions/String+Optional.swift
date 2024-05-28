
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

extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        switch self {
            case .some(let string):
                return string.isEmpty
            case .none:
                return true
        }
        
    }
}
