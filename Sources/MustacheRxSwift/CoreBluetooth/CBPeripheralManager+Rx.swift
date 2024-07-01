
#if canImport(CoreBluetooth)
import CoreBluetooth

#if canImport(RxSwift)
import RxSwift

class RxCBPeripheralManagerDelegate: NSObject, CBPeripheralManagerDelegate {
    
    /// Typed parent object.
    weak fileprivate(set) var manager: CBPeripheralManager?
    
    /// - parameter manager: Parent object for delegate proxy.
    init(manager: CBPeripheralManager) {
        super.init()
        self.manager = manager
        self.manager?.delegate = self
    }
    
    fileprivate let didUpdateState = ReplaySubject<CBManagerState>.create(bufferSize: 1)
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        self.didUpdateState.onNext(peripheral.state)
    }
    
    deinit {
        self.didUpdateState.onCompleted()
    }
    
}

// swiftlint:disable identifier_name
public extension Reactive where Base: CBPeripheralManager {
    
    internal var delegate: RxCBPeripheralManagerDelegate {
        return RxCBPeripheralManagerDelegate(manager: base)
    }
    
    var didUpdateState: RxObservable<CBManagerState> { return self.delegate.didUpdateState }
        
}

#endif

#endif
