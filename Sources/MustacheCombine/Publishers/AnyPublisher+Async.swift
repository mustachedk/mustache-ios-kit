
import Combine

// Credits https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77

public enum AsyncError: Error {
    case finishedWithoutValue
}

@available(macOS 10.15, *)
public extension AnyPublisher {
    
    
    /// Converts a publisher to a async function the returns all the values in a list after the publisher completes.
    /// - Returns: A list of Elements
    func asyncReduce() async throws -> [Output] {
        
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = self.reduce([Output]()) { initialResult, nextPartialResult in
                var next = initialResult
                next.append(nextPartialResult)
                return next
            }
            .sink { result in
                switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                }
                cancellable?.cancel()
            } receiveValue: { value in
                finishedWithoutValue = false
                continuation.resume(with: .success(value))
            }
        }
    }
    
    
}



@available(macOS 10.15, *)
public extension AnyPublisher {
    
    /// Converts a publisher to a async function the returns the first value from the publisher.
    /// /// - Returns: The first element from the publisher
    func asyncFirst() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = self.first()
                .sink { result in
                    switch result {
                        case .finished:
                            if finishedWithoutValue {
                                continuation.resume(throwing: AsyncError.finishedWithoutValue)
                            }
                        case let .failure(error):
                            continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
