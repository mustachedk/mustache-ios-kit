
#if canImport(UIKit)

import Foundation
import UIKit

import RxSwift

public extension Reactive where Base: UIViewController {

    func dismiss(animated flag: Bool) -> Single<Void> {
        return Single.create { single in
            self.base.dismiss(animated: flag, completion: { single(.success(())) })
            return Disposables.create()
        }
    }

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool) -> Single<Void> {
        return Single.create { single in
            self.base.present(viewControllerToPresent, animated: flag, completion: { single(.success(())) })
            return Disposables.create()
        }
    }

}

#endif
