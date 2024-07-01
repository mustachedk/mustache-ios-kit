
import Foundation

import Combine

@available(iOS 13.0, macOS 10.15, *)
public extension Publisher {
    /// Replace each upstream value with a constant.
    ///
    /// - Parameter value: The constant with which to replace each upstream value.
    /// - Returns: A new publisher wrapping the upstream, but with output type `Value`.
    func mapTo<Value>(_ value: Value) -> AnyPublisher<Value, Self.Failure> {
        return self
            .map { _ in value }
            .eraseToAnyPublisher()
    }
    
    /// Replace each upstream value with Void.
    ///
    /// - Returns: A new publisher wrapping the upstream and replacing each element with Void.
    func mapVoid() -> AnyPublisher<Void, Self.Failure> {
        return self
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
