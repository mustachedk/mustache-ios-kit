
import Foundation

class StoredObject: Codable, Equatable {
    
    var id: UUID = UUID()
    
    static func == (lhs: StoredObject, rhs: StoredObject) -> Bool {
        return lhs.id == rhs.id
    }
    
}

