
import Foundation

import MustacheServices

import RxSwift
import Resolver

public protocol RenewTokenServiceType {

    var token: RxObservable<Void> { get }

    func trackErrors<O: ObservableConvertibleType>(for source: O) -> RxObservable<Void> where O.Element == Error

}

public class RenewTokenService: RenewTokenServiceType {

    public lazy var token: RxObservable<Void> = {
        return self.relay
                .flatMapFirst { _ in self.tokenService.updateToken() }
                .startWith(Void())
                .share(replay: 1)
    }()

    @Injected
    fileprivate var tokenService: TokenServiceType
    
    @Injected
    fileprivate var credentialsService: CredentialsServiceType

    public init() {}

    /**
     Monitors the source for `.unauthorized` error events and passes all other errors on. When an `.unauthorized` error is seen, `self` will get a new token and emit a signal that it's safe to retry the request.

     - parameter source: An `Observable` (or like type) that emits errors.
     - returns: A trigger that will emit when it's safe to retry the request.
     */
    public func trackErrors<O: ObservableConvertibleType>(for source: O) -> RxObservable<Void> where O.Element == Error {
        let lock = self.lock
        let relay = self.relay
        let error = source
                .asObservable()
                .map { error in
                    guard (error as? RenewTokenError) == .unauthorized else { throw error }
                }
                .flatMap { [unowned self] in self.token }
                .do(onNext: {
                    lock.lock()
                    relay.onNext($0)
                    lock.unlock()
                })
                .filter { _ in false }
                .map { _ in }

        return Observable.merge(token.skip(1).map { _ in }, error)
    }

    private let relay = PublishSubject<Void>()
    private let lock = NSRecursiveLock()

    public func clearState() {}
}

public extension ObservableConvertibleType where Element == Error {

    func renewToken(with service: RenewTokenServiceType) -> RxObservable<Void> {
        return service.trackErrors(for: self)
    }
}

public enum RenewTokenError: Error, Equatable {
    case unauthorized
    case refusedToken
}
