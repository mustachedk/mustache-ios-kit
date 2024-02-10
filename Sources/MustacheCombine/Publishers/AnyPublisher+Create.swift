
import Foundation
import Combine

// Credits: https://stackoverflow.com/a/73736693/1366083
extension AnyPublisher {
    
    static func create<O, F>(_ subscribe: @escaping (AnySubscriber<O, F>) -> AnyCancellable) -> AnyPublisher<O, F> {
        
        let passthroughSubject = PassthroughSubject<O, F>()
        var cancellable: AnyCancellable?
        
        return passthroughSubject
            .handleEvents(receiveSubscription: { subscription in
                
                let subscriber = AnySubscriber<O, F> { subscription in
                    
                } receiveValue: { input in
                    passthroughSubject.send(input)
                    return .unlimited
                } receiveCompletion: { completion in
                    passthroughSubject.send(completion: completion)
                }
                
                cancellable = subscribe(subscriber)
                
            }, receiveCompletion: { completion in
                
            }, receiveCancel: {
                cancellable?.cancel()
            })
            .eraseToAnyPublisher()
        
    }
    
}
