
import Foundation
import UIKit
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency

extension UIViewController {
    
    func requestTrackingAuthorization(_ completion: @escaping () -> Void) -> Bool {
        guard ATTrackingManager.trackingAuthorizationStatus.rawValue != ATTrackingManager.AuthorizationStatus.notDetermined.rawValue else {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                DispatchQueue.main.async(execute: { completion() })
            })
            return false
        }
        return true
    }
}

#endif
