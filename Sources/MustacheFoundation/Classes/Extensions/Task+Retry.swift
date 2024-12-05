
import Foundation

// Credits https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/

@available(macOS 10.15, *)
public extension Task where Failure == Error {
    
    @discardableResult
    static func retrying(priority: TaskPriority? = nil, maxRetryCount: Int = 3, retryDelay: TimeInterval = 1, operation: @Sendable @escaping () async throws -> Success) -> Task {
        Task(priority: priority) {
            for attempt in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let exponent = pow(retryDelay, Double(attempt))
                    let delay = UInt64(oneSecond * exponent)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
