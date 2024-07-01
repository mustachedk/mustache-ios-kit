#if canImport(UIKit)

import Foundation
import UIKit

public extension UIScrollView {
    
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width)
    }
    
    var previousPage: Int {
        return self.isScrolledToBegining ? self.currentPage : self.currentPage - 1
    }
    
    var nextPage: Int {
        return self.isScrolledToEnd ? self.currentPage : self.currentPage + 1
    }
    
    var scrollDirection: UICollectionView.ScrollDirection? {
        if self.contentSize.width > self.contentSize.height {
            return .horizontal
        } else if self.contentSize.height > self.contentSize.width {
            return .vertical
        } else {
            return nil
        }
    }
    
    var isScrolledToBegining: Bool {
        
        switch self.scrollDirection {
            case .horizontal:
                return self.contentOffset.x == 0
            case .vertical:
                return self.contentOffset.y == 0
            default:
                return self.contentOffset.x == 0 && self.contentOffset.y == 0
        }
    }
    
    var isScrolledToEnd: Bool {
        
        switch self.scrollDirection {
            case .horizontal:
                return self.contentOffset.x + self.frame.size.width >= self.contentSize.width
            case .vertical:
                return self.contentOffset.y + self.frame.size.height >= self.contentSize.height
            default:
                return self.contentOffset.x + self.frame.size.width >= self.contentSize.width &&
                self.contentOffset.y + self.frame.size.height >= self.contentSize.height
                
        }
    }
}

#endif
