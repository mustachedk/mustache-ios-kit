
import Foundation

public func <<T: Comparable>(left: T?, right: T) -> Bool {
    if let left = left {
        return left < right
    }
    return false
}

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T: Comparable {
    return min(max(value, minValue), maxValue)
}

