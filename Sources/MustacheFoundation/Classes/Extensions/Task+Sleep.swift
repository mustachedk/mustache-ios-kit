
import Foundation

@available(iOS 16.0, macOS 10.15, *)
public extension Task {
    
    static func sleep(until target: Date) async throws where Success == Never, Failure == Never {
        let duration = target.timeIntervalSinceNow
        if #available(macOS 13.0, watchOS 9.0 , *) {
            try await Self.sleep(for: .seconds(duration))
        } else if #available(macOS 15.0, *) {
            try await Self.sleep(nanoseconds: UInt64(duration * 1000))
        } else {
            fatalError("used from unsupport os version")
        }
    }
    
}
