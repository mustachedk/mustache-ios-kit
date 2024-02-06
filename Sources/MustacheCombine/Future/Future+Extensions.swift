
import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, *)
public extension Future where Failure == Error {
    
    convenience init(asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
