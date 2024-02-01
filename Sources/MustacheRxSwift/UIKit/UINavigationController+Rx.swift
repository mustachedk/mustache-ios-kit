import Foundation
import UIKit

import RxSwift

public extension Reactive where Base: UINavigationController {

    func pushViewController(viewController: UIViewController, animated flag: Bool) -> Single<Void> {
        return Single.create { single in
            self.base.pushViewController(viewController: viewController, animated: flag, completion: { single(.success(())) })
            return Disposables.create()
        }
    }

    func popViewController(animated flag: Bool) -> Single<Void> {
        return Single.create { single in
            self.base.popViewController(animated: flag, completion: { single(.success(())) })
            return Disposables.create()
        }
    }

    func popToRootViewController(animated flag: Bool) -> Single<Void> {
        return Single.create { single in
            self.base.popToRootViewController(animated: flag, completion: { single(.success(())) })
            return Disposables.create()
        }
    }

}
