#if canImport(CoreLocation)

import CoreLocation

#if canImport(RxSwift)

import RxSwift

class RxCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {

    /// Typed parent object.
    public weak fileprivate(set) var clLocationManager: CLLocationManager?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(clLocationManager: CLLocationManager) {
        super.init()
        self.clLocationManager = clLocationManager
        self.clLocationManager?.delegate = self
        
    }
    
    fileprivate let didUpdateLocations = ReplaySubject<[CLLocation]>.create(bufferSize: 1)
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.didUpdateLocations.onNext(locations)
    }
    
    fileprivate let didFailWithError = ReplaySubject<Error>.create(bufferSize: 1)
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.didFailWithError.onNext(error)
    }
    
    fileprivate let didChangeAuthorizationStatus = ReplaySubject<CLAuthorizationStatus>.create(bufferSize: 1)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            self.didChangeAuthorizationStatus.onNext(manager.authorizationStatus)
        } else {
            self.didChangeAuthorizationStatus.onNext(CLLocationManager.authorizationStatus())
        }
    }

}

public extension Reactive where Base: CLLocationManager {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    
    internal var delegate: RxCLLocationManagerDelegate {
        return RxCLLocationManagerDelegate(clLocationManager: base)
    }

    var didUpdateLocations: RxObservable<[CLLocation]> {
        return self.delegate.didUpdateLocations.asObservable()
    }
    
    var didFailWithError: RxObservable<Error> {
        return self.delegate.didFailWithError.asObservable()
    }
    
    @available(iOS 14.0, macOS 15, *)
    var didChangeAuthorizationStatus: RxObservable<CLAuthorizationStatus> {
        return self.delegate.didChangeAuthorizationStatus.asObservable()
    }
    
}

#endif

#endif
