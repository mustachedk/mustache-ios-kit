
#if canImport(UIKit)

import Foundation
import UserNotifications
import UIKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

public extension Reactive where Base: UNUserNotificationCenter {

    var isAuthorized: RxObservable<Bool> {
        return UIApplication.shared.rx.applicationDidBecomeActive
                .startWith(())
                .flatMap { [base = self.base] _ -> RxObservable<Bool> in
                    return RxObservable<Bool>.create { observer in
                        base.getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) in
                            guard settings.authorizationStatus == .authorized else { observer.onNext(false); return; }
                            observer.onNext(true)
                        })
                    return Disposables.create()
                }
        }
    }

    func requestAuthorization(options: UNAuthorizationOptions = []) -> RxObservable<Bool> {
        return RxObservable.create { (observer: AnyObserver<Bool>) in
            DispatchQueue.main.async {
                self.base.requestAuthorization(options: options, completionHandler: { (_ granted: Bool, _ error: Error?) -> Void in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(granted)
                        observer.onCompleted()
                        if granted { DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() } }

                    }
                })
            }
            return Disposables.create()
        }
    }

    func getNotificationSettings() -> RxObservable<UNNotificationSettings> {
        return RxObservable.create { (observer: AnyObserver<UNNotificationSettings>) in
            DispatchQueue.main.async {
                self.base.getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) -> Void in
                    observer.onNext(settings)
                    observer.onCompleted()
                })
            }
            return Disposables.create()
        }
    }

}

#endif

#endif
