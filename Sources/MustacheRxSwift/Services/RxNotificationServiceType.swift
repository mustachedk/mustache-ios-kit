import Foundation
import UserNotifications
import RxSwift
import MustacheServices
import UIKit

public protocol RxNotificationServiceType {

    func registerForPushNotifications() -> Observable<Bool>

}

public final class RxNotificationService: RxNotificationServiceType {

    public init() {}

    public func registerForPushNotifications() -> Observable<Bool> {
        return Observable<Bool>.create { (observer) in
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(granted)
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
                .do(onNext: { [weak self] granted in
                    if granted { self?.getNotificationSettings() }
                })
    }

    fileprivate func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

}
