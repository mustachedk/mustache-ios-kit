
#if canImport(UIKit)

import Foundation
import UIKit

import RxSwift


public extension Reactive where Base: UICollectionView {

    /// Bindable sink for `selected` property.
    var reloadData: Binder<Void> {
        return Binder(self.base) { control, _ in
            control.reloadData()
        }
    }
}

#endif
