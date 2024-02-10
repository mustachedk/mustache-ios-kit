
import Foundation
import Combine

@available(iOS 14.0, *)
public extension Publisher {
    
    func tryAwaitMap<T>(_ transform: @escaping (Self.Output) async throws -> T) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let result = try await transform(value)
                        promise(.success(result))
                    }
                    catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    func tryAwaitMap<T>(_ transform: @escaping (Self.Output) async throws -> T) -> Publishers.FlatMap<Future<T, Error>, Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let result = try await transform(value)
                        promise(.success(result))
                    }
                    catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
