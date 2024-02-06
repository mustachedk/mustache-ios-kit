
#if canImport(UIKit)

import Foundation
import UIKit

@available(iOS 13.0, macOS 15, *)
public extension UINavigationController {
    
    func pushViewControllerAsync(viewController: UIViewController, animated: Bool) async  {
        
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
             
            DispatchQueue.main.async {
                self.pushViewController(viewController: viewController, animated: animated) {
                    continuation.resume()
                }
            }
        }
    }
    
    func popViewControllerAsync(animated: Bool) async {
        
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            DispatchQueue.main.async {
                self.popViewController(animated: animated) {
                    continuation.resume()
                }
            }
        }
    }
    
    func popToRootViewControllerAsync(animated: Bool) async  {
        
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            DispatchQueue.main.async {
                self.popToRootViewController(animated: animated) {
                    continuation.resume()
                }
            }
        }
    }
    
}

#endif
