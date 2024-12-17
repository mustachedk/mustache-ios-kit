
import Foundation
import Network

public typealias ConnectionAvailableHandler = (Bool) -> ()

public protocol ConnectivityServiceType: AnyObject {
 
    var handler: ConnectionAvailableHandler? { get set }
    
}

public class ConnectivityService: ConnectivityServiceType {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityService")
    
    public var handler: ConnectionAvailableHandler? = nil {
        didSet {
            if self.handler != nil {
                self.startMonitoring()
            } else {
                self.stopMonitoring()
            }
        }
    }
    
    public init() {
        self.configure()
    }
    
    private func configure () {
        self.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.handler?(true)
            } else {
                self.handler?(false)
            }
        }
    }
    
    private func startMonitoring() {
        self.monitor.start(queue: self.queue)
    }
    
    private func stopMonitoring() {
        self.monitor.cancel()
    }
    
}


