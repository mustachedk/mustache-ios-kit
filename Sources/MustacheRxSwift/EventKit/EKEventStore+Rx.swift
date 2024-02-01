
#if canImport(EventKit)

import Foundation
import EventKit
import RxSwift


public extension Reactive where Base: EKEventStore {
    
    func requestAccess(to entityType: EKEntityType) -> RxObservable<Bool> {
        return RxObservable.create { observer in
            self.base.requestAccess(to: entityType) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        observer.on(.error(error))
                    } else {
                        observer.on(.next(granted))
                    }
                    observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
}

#endif
