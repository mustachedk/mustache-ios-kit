
// Credits https://stackoverflow.com/a/69762412/1366083

import Foundation
import Combine

@available(macOS 10.15, *)
public extension Publisher {
    
    
    /// A publisher that completes after the specified interval, or never if no interval is specified.
    /// - Parameters:
    ///   - interval: Time before the publisher completes.
    ///   - tolerance: The allowed tolerance in delivering delayed events. The stopAfter publisher may complete this much sooner or later than the interval specifies.
    ///   - scheduler: The scheduler to deliver the timed out events.
    ///   - options: Options relevant to the scheduler’s behavior.
    /// - Returns: Returns a publisher that completes after the specified interval, or never if no interval is specified.
    func stopAfter<S>(_ interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) -> AnyPublisher<Output, Failure> where S: Scheduler {
        self.prefix(untilOutputFrom: Just(()).delay(for: interval, tolerance: tolerance, scheduler: scheduler, options: options))
            .eraseToAnyPublisher()
    }
    
}
