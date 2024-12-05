
import Foundation

public extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
   subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    @available(*, deprecated, message: "Double negation, hard to read, use hasElements instead")
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var hasElements: Bool {
        return !self.isEmpty
    }
        
}
