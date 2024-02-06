#if canImport(UIKit)

import Foundation
import UIKit

public extension UIScrollView {
    
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width)
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
}

#endif
