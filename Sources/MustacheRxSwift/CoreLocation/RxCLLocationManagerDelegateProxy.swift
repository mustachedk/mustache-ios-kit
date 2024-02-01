#if canImport(CoreLocation)

import CoreLocation

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

public class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {

    /// Typed parent object.
    public weak fileprivate(set) var clLocationManager: CLLocationManager?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(clLocationManager: ParentObject) {
        self.clLocationManager = clLocationManager
        super.init(parentObject: clLocationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(clLocationManager: $0) }
    }

    public static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        return object.delegate
    }

    public static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        object.delegate = delegate
    }

}

#endif

#endif
