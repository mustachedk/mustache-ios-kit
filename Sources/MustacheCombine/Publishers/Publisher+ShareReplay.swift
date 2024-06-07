
import Foundation
import Combine

public extension Publisher {
    
    /// Provides a subject that shares a single subscription to the upstream publisher and
    /// replays at most `bufferSize` items emitted by that publisher
    /// - Parameter bufferSize: limits the number of items that can be replayed
    func shareReplay(_ bufferSize: Int) -> AnyPublisher<Output, Failure> {
        return multicast(subject: ReplaySubject(bufferSize: bufferSize)).autoconnect().eraseToAnyPublisher()
    }
}
