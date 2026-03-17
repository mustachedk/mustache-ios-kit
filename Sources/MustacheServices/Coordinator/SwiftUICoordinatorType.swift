
import Foundation

/// A coordinator protocol for pure SwiftUI navigation that has no UIKit dependencies.
/// Conforming types manage navigation through @Published properties and NavigationStack paths.
@MainActor
public protocol SwiftUICoordinatorType: AnyObject, ObservableObject {

    func start() throws

    func transition(to transition: Transition) throws

    func route(to route: Route)

}

public extension SwiftUICoordinatorType {

    func route(to route: Route) {}

}
