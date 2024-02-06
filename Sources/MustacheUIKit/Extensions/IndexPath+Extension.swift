#if canImport(UIKit)
import UIKit

public extension IndexPath {

    /// First item in UICollectionView
    static let firstItem = IndexPath(item: 0, section: 0)

    /// First row in UITableView
    static let firstRow = IndexPath(row: 0, section: 0)

    /// Next item in UICollectionView
    var nextItem: IndexPath { return IndexPath(item: self.item + 1, section: self.section) }

    /// Next row in UITableView
    var nextRow: IndexPath { return IndexPath(row: self.row + 1, section: self.section) }

    /// Is this IndexPath odd
    var odd: Bool { return (self.row % 2) == 1 || (self.item % 2) == 1 }

    /// Is this IndexPath even
    var even: Bool { return !odd }

}
#endif
