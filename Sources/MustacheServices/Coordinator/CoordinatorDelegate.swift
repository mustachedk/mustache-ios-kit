import Foundation

#if os(iOS)

public protocol CoordinatorDelegate: CoordinatorType {
    
    func completed(child: (any CoordinatorType)?, completion: Completion?)
    
}

public extension CoordinatorDelegate {
    
    func completed(child: (any CoordinatorType)?) {
        self.completed(child: child, completion: nil)
    }
    
    func completed(child: (any CoordinatorType)?, completion: Completion?) {}
    
}

#endif
