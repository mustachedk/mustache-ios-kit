
import Foundation
import UIKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

public extension Reactive where Base: UIButton {

    var isHighlighted: RxObservable<Bool> {

        let anyObservable = self.base.rx.methodInvoked(#selector(setter: self.base.isHighlighted))

        let boolObservable = anyObservable
                .flatMap { RxObservable.from(optional: $0.first as? Bool) }
                .startWith(self.base.isHighlighted)
                .distinctUntilChanged()
                .share()

        return boolObservable
    }
}

#endif
