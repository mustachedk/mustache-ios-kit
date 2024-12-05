
import Foundation

public extension Array where Element: Equatable {
    
    mutating func rearrange(fromIndex: Int, toIndex: Int) {
        let element = self.remove(at: fromIndex)
        self.insert(element, at: toIndex)
    }

    mutating func moveToFront(element: Element) {
        guard let index = self.firstIndex(where: { index -> Bool in return index == element }) else { return }
        self.rearrange(fromIndex: index, toIndex: 0)
    }

    @discardableResult
    mutating func remove(element: Element) -> Int {
        guard let index = self.firstIndex(where: { index -> Bool in return index == element }) else { return -1 }
        self.remove(at: index)
        return index
    }

    @discardableResult
    mutating func remove(elements: [Element]) -> [Element] {
        for element in elements {
            guard let index = self.firstIndex(where: { index -> Bool in return index == element }) else { continue }
            self.remove(at: index)
        }
        return self
    }
    
    @discardableResult
    mutating func replace(_ element: Element, with new: Element) -> Bool {
        if let f = self.firstIndex(where: { $0 == element }) {
            self[f] = new
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func appending(_ element: Element) -> Self {
        self.append(element)
        return self
    }
    
    func uniques() -> Array {
        var seen = Array<Element>()
        for element in self {
            if seen.contains(element) { continue }
            seen.append(element)
        }
        return seen
    }
    
    static func +(lhs: Array, rhs: Array) -> Array {
        var array = Array(lhs)
        array.append(contentsOf: rhs)
        return array
    }
    
    static func -(lhs: Array, rhs: Array) -> Array {
        return lhs.filter { lhsElement in return !rhs.contains(lhsElement) }
    }
}

public extension Array {

    var middle: Element? {
        guard count != 0 else { return nil }
        guard (count % 2) == 1 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }

    func grouped<T>(by criteria: (Element) -> T) -> [T: [Element]] {
        var groups = [T: [Element]]()
        for element in self {
            let key = criteria(element)
            if groups.keys.contains(key) == false {
                groups[key] = [Element]()
            }
            groups[key]?.append(element)
        }
        return groups
    }
}

public extension ArraySlice {
    
    var array: [Element] { return Array(self) }
}

public extension Array where Element: Hashable {
    
    var set: Set<Element> {
        return Set(self)
    }
    
}

public extension Array {
    init(count: Int, createElement: @autoclosure () -> Element) {
        self = (0 ..< count).map { _ in createElement() }
    }
}
