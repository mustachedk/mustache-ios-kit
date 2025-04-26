import Foundation
#if os(iOS)
import UIKit

// https://medium.com/concretelatinoamérica/inverse-reference-coordinator-pattern-d5a5948c0d90
public protocol CoordinatorType: NSObjectProtocol {
    
    var baseController: UIViewController? { get }
    
    func start() throws
    
    func stop() throws
    
    func stop(with completion: Completion?) throws
    
    func transition(to transition: Transition) throws
    
    func route(to route: Route)
    
}

public extension CoordinatorType {
    
    func stop() throws {
        try self.stop(with: nil)
    }
    
    func stop(with completion: Completion?) throws { }
    
    func route(to route: Route) throws {}
    
}

public protocol Transition {
    
}

public protocol Completion {
    
}

public protocol Route {
    
}

#endif
