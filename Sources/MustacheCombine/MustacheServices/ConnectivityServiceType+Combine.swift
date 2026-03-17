
import Foundation
import Combine
import Factory

import MustacheServices

public protocol CombineConnectivityServiceType {
    
    var handlerPublisher: AnyPublisher<Bool, Never>  { get }
    
}

public class CombineConnectivityService: CombineConnectivityServiceType  {
    
    public var handlerPublisher: AnyPublisher<Bool, Never>  {
        return handlerSubject.eraseToAnyPublisher()
    }
    
    private var handlerSubject = PassthroughSubject<Bool, Never>()

    @Injected(\.connectivityService) private var connectivityService: (any ConnectivityServiceType)?
    
    public init() {
        self.configure()
    }
    
    private func configure() {
        self.connectivityService?.handler = { [weak self] isConnected in
            self?.handlerSubject.send(isConnected)
        }
    }
}
