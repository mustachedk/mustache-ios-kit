import Combine

public extension Publisher {
    
    func enumerated() -> AnyPublisher<(Int, Self.Output), Self.Failure> {
        scan(Optional<(Int, Self.Output)>.none) { acc, next in
            guard let acc = acc else { return (0, next) }
            return (acc.0 + 1, next)
        }
        .map { $0! }
        .eraseToAnyPublisher()
    }
}
