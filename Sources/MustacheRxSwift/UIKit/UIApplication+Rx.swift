
import UIKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa


public extension Reactive where Base: UIApplication {

    /**
     Reactive wrapper for `UIApplication.willEnterForegroundNotification`.
     */
    var applicationWillEnterForeground: RxObservable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).mapVoid()
    }

    /**
     Reactive wrapper for `UIApplication.didBecomeActiveNotification`.
     */
    var applicationDidBecomeActive: RxObservable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).mapVoid()
    }

    /**
     Reactive wrapper for `UIApplication.didBecomeActiveNotification`.
     */
    var applicationDidEnterBackground: RxObservable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).mapVoid()
    }

    /**
     Reactive wrapper for `UIApplication.willResignActiveNotification`.
     */
    var applicationWillResignActive: RxObservable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).mapVoid()
    }

    /**
     Reactive wrapper for `UIApplication.willTerminateNotification`.
     */
    var applicationWillTerminate: RxObservable<Void> {
        return NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification).mapVoid()
    }

}

#endif
