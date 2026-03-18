
import Foundation
#if os(iOS)
import UIKit

@MainActor
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

    public func stop() throws {
        try self.coordinator.stop()
    }
    
    public func stop(with completion: Completion?) throws {
        try self.coordinator.stop(with: completion)
    }
    
    
}

public extension HostingCoordinator {
    
    static var preview: HostingCoordinator {
        HostingCoordinator(coordinator: PreviewCoordinator.preview)
    }
}

@MainActor
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
