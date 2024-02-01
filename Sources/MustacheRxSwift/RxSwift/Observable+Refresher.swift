
import Foundation

import RxSwift

public extension RxObservable {
    
    /**
     Returns an observable sequence that produces a value every 5 minutes on the minute count 5 on a random second count
     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)
     */
    
    static func refresher() -> RxObservable<Void> {
        return RxObservable<Int>.timer(.seconds(0), period: .seconds(60), scheduler: MainScheduler.instance)
            .filter({ state in
                let minute = Calendar.daDK.component(.minute, from: .nowSafe)
                let remainder = minute % 5
                return remainder == 0 || state == 0
            })
            .mapVoid()
    }
    
}
