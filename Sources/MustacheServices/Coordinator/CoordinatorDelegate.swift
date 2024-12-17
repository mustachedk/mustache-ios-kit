import Foundation

public protocol CoordinatorDelegate: CoordinatorType {
    
    func completed(child: CoordinatorType?, completion: Completion?)
    
}

public extension CoordinatorDelegate {
    
    func completed(child: CoordinatorType?) {
        self.completed(child: child, completion: nil)
    }
    
    func completed(child: CoordinatorType?, completion: Completion?) {}
    
}
