#if canImport(UIKit)

import Foundation
import UIKit

/// A collection that will snap so that the cell on the left will be inset just like content inset
public class SnappingCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        // Page width used for estimating and calculating paging.
        let pageWidth: CGFloat = self.itemSize.width + self.minimumLineSpacing

        // Make an estimation of the current page position.
        let approximatePage: CGFloat = self.collectionView!.contentOffset.x / pageWidth

        // Determine the current page based on velocity.
        let currentPage = (velocity.x < 0.0) ? floor(approximatePage) : ceil(approximatePage)

        // Create custom flickVelocity.
        let flickVelocity = velocity.x * 0.3

        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)

        // Calculate newHorizontalOffset.
        let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - self.collectionView!.contentInset.left

        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}

#endif
