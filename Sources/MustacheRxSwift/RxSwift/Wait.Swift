import Foundation
import RxSwift


public extension ObservableType {

    func wait(until observable: RxObservable<Void>) -> RxObservable<Element> {
        RxObservable.combineLatest(
                observable.enumerated().filter({ $0.index == 0 }),
                self
        ) { _, element in
            return element
        }
    }

}
