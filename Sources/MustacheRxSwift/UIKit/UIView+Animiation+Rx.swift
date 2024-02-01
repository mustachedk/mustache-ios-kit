import Foundation
import UIKit

import RxSwift

public extension Reactive where Base: UIView {

    var animatedAlpha: Binder<CGFloat> {
        return Binder(self.base) { view, alpha in
            UIView.animate(withDuration: 0.3) {
                view.alpha = alpha
            }
        }
    }
    
    static func animate(withDuration: TimeInterval, animations: @escaping () -> Void) -> Single<Bool> {

        return Single.create { single in
            UIView.animate(withDuration: withDuration, animations: animations, completion: {
                finished in single(.success(finished))
            })
            return Disposables.create()
        }
    }

}
