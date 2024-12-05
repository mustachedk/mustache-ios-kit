
#if canImport(CoreBluetooth)
import CoreBluetooth

#if canImport(RxCocoa)
import RxSwift
import RxCocoa

// swiftlint:disable identifier_name
public extension Reactive where Base: CBPeripheralManager {
    
    var delegate: CBPeripheralManagerDelegateProxy {
        return CBPeripheralManagerDelegateProxy.proxy(for: base)
    }
    
    var state: RxObservable<CBManagerState> { return self.delegate.didUpdateState }
    
    var didUpdateState: RxObservable<Void> { return delegate.didUpdateState.map { _ in } }
    
    // optional methods are setup using the `methodInvoked` function on the delegate
    var willRestoreState: RxObservable<[String: Any]> {
        return delegate.methodInvoked(#selector(CBPeripheralManagerDelegate.peripheralManager(_:willRestoreState:)))
            .map { $0[1] as! [String: Any] }
    }
    
    var didStartAdvertising: RxObservable<Error?> {
        return delegate.methodInvoked(#selector(CBPeripheralManagerDelegate.peripheralManagerDidStartAdvertising(_:error:)))
            .map { $0[1] as? Error }
    }
    
}

// The HasDelegate protocol is an associated type for the DelegateProxyType
extension CBPeripheralManager: HasDelegate {
    public typealias Delegate = CBPeripheralManagerDelegate
}

public class CBPeripheralManagerDelegateProxy: DelegateProxy<CBPeripheralManager, CBPeripheralManagerDelegate>, DelegateProxyType, CBPeripheralManagerDelegate {
    
    fileprivate let didUpdateState = PublishSubject<CBManagerState>()
    
    init(parentObject: CBPeripheralManager) {
        super.init(parentObject: parentObject, delegateProxy: CBPeripheralManagerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        register { CBPeripheralManagerDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: CBPeripheralManager) -> CBPeripheralManagerDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: CBPeripheralManagerDelegate?, to object: CBPeripheralManager) {
        object.delegate = delegate
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        self.didUpdateState.onNext(peripheral.state)
    }
    
    deinit {
        self.didUpdateState.onCompleted()
    }
    
}

#endif

#endif
