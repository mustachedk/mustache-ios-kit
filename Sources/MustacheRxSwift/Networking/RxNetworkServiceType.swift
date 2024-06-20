
import Foundation

import MustacheServices

import RxSwift
import Resolver

public protocol RxNetworkServiceType {
    
    func send<T: Decodable>(endpoint: Endpoint) -> Single<T>
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) -> Single<T>
    
}

public class RxNetworkService: NSObject, RxNetworkServiceType {

    @Injected
    fileprivate var networkService: NetworkServiceType

    fileprivate var renewTokenService: RenewTokenServiceType? = Resolver.optional()

    public override init() {
        super.init()
    }

    public func send<T: Decodable>(endpoint: Endpoint) -> Single<T> {
        return self.send(endpoint: endpoint, using: JSONDecoder())
    }

    public func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) -> Single<T> {

        if let renewService = self.renewTokenService, (endpoint.authentication == .bearer || endpoint.authentication == .oauth) {
            var count = 3
            return Observable
                    .deferred { renewService.token.take(1) }
                    .flatMap { _ in self.observable(endpoint: endpoint, using: decoder).asObservable() }
                    .catch { error in
                        guard let networkError = error as? NetworkServiceTypeError else { throw error }
                        switch networkError {
                            case .unauthorized(_):
                                count -= 1
                                throw RenewTokenError.unauthorized
                            case .unSuccessful(_, _, let code, _):
                                if (code == 403 || code == 401) && count > 0 {
                                    count -= 1
                                    throw RenewTokenError.unauthorized
                                } else {
                                    throw error
                                }
                            default: throw error
                        }
                    }
                    .retry { $0.renewToken(with: renewService) }
                    .asSingle()

        } else {
            return self.observable(endpoint: endpoint, using: decoder)
        }

    }

    fileprivate func observable<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) -> Single<T> {

        if let demoData = endpoint.demoData as? T { return Single<T>.just(demoData) }

        return Single<T>.create { [weak self] observer in
                    guard let self = self else {
                        observer(.failure(RxNetworkServiceTypeError.deallocated))
                        return Disposables.create()
                    }

                    let task = self.networkService.send(endpoint: endpoint, using: decoder, completionHandler: { (result: Result<T, Error>) in

                        switch result {
                            case .success(let model):
                                observer(.success(model))
                            case .failure(let error):
                                observer(.failure(error))
                        }

                    })

                    return Disposables.create {
                        task.cancel()
                    }
                }
        .observe(on: MainScheduler.instance)
    }
}

enum RxNetworkServiceTypeError: Error {
    case deallocated
}
