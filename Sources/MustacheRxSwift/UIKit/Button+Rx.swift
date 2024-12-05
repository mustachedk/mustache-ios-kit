
import MustacheUIKit

import RxSwift

public extension Reactive where Base: Button {

    /// Bindable sink for `hidden` property.
    var isBusy: Binder<Bool> {
        return Binder(self.base) { view, busy in
            view.isBusy = busy
        }
    }
}

public extension RxObservable {

    func busy(button: Button) -> RxObservable<Element> {
        return self.do(onSubscribe: { [weak button] in
            button?.isBusy = true
        }, onDispose: { [weak button] in
            button?.isBusy = false
        })
    }
}
