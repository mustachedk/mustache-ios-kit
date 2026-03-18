
import Foundation
import UIKit

/// A coordinator protocol for pure SwiftUI navigation that has no UIKit dependencies.
/// Conforming types manage navigation through @Published properties and NavigationStack paths.
@MainActor
public protocol UIKitCoordinatorType: CoordinatorType { 
    
    var baseController: UIViewController? { get }
    
}
