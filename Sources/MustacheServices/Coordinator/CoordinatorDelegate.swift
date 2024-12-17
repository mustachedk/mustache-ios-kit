import Foundation

public protocol CoordinatorDelegate: CoordinatorType {
    
    func completed(child: CoordinatorType?)
    
}

public extension CoordinatorDelegate {
    
    func completed(child: CoordinatorType?) {}
    
}
