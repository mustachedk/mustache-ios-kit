
import Foundation

public extension Task {
    
    static func sleep(until target: Date) async throws where Success == Never, Failure == Never {
        let duration = target.timeIntervalSinceNow
        if #available(iOS 16.0, *) {
            try await Self.sleep(for: .seconds(duration))
        } else {
            try await Self.sleep(nanoseconds: UInt64(duration * 1000))
        }
    }
    
}
