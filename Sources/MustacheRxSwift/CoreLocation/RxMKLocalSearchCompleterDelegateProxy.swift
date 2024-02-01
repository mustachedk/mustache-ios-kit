#if canImport(CoreLocation)

import CoreLocation
import MapKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

extension MKLocalSearchCompleter: HasDelegate {
    public typealias Delegate = MKLocalSearchCompleterDelegate
}

public class RxMKLocalSearchCompleterDelegateProxy: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate>, DelegateProxyType, MKLocalSearchCompleterDelegate {

    /// Typed parent object.
    public weak fileprivate(set) var localSearchCompleter: MKLocalSearchCompleter?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(localSearchCompleter: ParentObject) {
        self.localSearchCompleter = localSearchCompleter
        super.init(parentObject: localSearchCompleter, delegateProxy: RxMKLocalSearchCompleterDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxMKLocalSearchCompleterDelegateProxy(localSearchCompleter: $0) }
    }

    public static func currentDelegate(for object: MKLocalSearchCompleter) -> MKLocalSearchCompleterDelegate? {
        return object.delegate
    }

    public static func setCurrentDelegate(_ delegate: MKLocalSearchCompleterDelegate?, to object: MKLocalSearchCompleter) {
        object.delegate = delegate
    }

}

#endif

#endif
