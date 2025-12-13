
import Foundation
#if os(iOS)
import UIKit

    // This is a solution to avoid having multiple references to view models in the SwiftUI containing view controllers
    // Instead of having multiple actions/handlers/closure in different view models for handling transitions, we can now use
    // this wrapper to Inject CoordinatorTypes directly to SwiftUI views using environmentObject()

public class HostingCoordinator: ObservableObject {
    
    public let coordinator: any CoordinatorType
    
    public init(coordinator: any CoordinatorType) {
        self.coordinator = coordinator
    }
    
    public func transition(to transition: Transition) throws {
        try self.coordinator.transition(to: transition)
    }
    
    public func route(to route: any Route) {
        self.coordinator.route(to: route)
    }

    func stop() throws {
        try self.coordinator.stop()
    }
    
    func stop(with completion: Completion?) throws {
        try self.coordinator.stop(with: completion)
    }
    
    
}

public extension HostingCoordinator {
    
    static var preview: HostingCoordinator {
        HostingCoordinator(coordinator: PreviewCoordinator.preview)
    }
}

public class PreviewCoordinator: NSObject, CoordinatorType  {
    
    public var baseController: UIViewController?
    
    public func start() throws { }
    
    public func transition(to transition: any Transition) throws { }
    
    public func route(to route: any Route) { }
    
}

public extension PreviewCoordinator {
    
    static var preview: PreviewCoordinator {
        PreviewCoordinator()
    }
}

#endif
