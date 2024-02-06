
import Foundation
import Resolver

@available(iOS 13.0, macOS 15, *)
public protocol AsyncNetworkServiceType {
    
    init()
    
    func send<T: Decodable>(endpoint: Endpoint) async throws -> T
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) async throws -> T
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder, retries: Int) async throws -> T
    
}

@available(iOS 13.0, macOS 15, *)
public extension AsyncNetworkServiceType {
    
    func send<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try await self.send(endpoint: endpoint, using: decoder, retries: 3)
    }
    
    func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder) async throws -> T {
        return try await self.send(endpoint: endpoint, using: decoder, retries: 3)
    }
    
}

@available(iOS 13.0, macOS 15, *)
public actor AsyncNetworkService: AsyncNetworkServiceType {
    
    @LazyInjected
    var tokenService: AsyncTokenServiceType
    
    @LazyInjected
    var credentialsService: AsyncCredentialsServiceType
    
    public init() { }
    
    public func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder, retries: Int) async throws -> T {
        
        if let demoData = endpoint.demoData as? T { return demoData }
        
        var request = endpoint.request()
        
        do {
            
            if endpoint.authentication == .oauth {
                
                do {
                    let token = try await self.tokenService.validToken()
                    request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                } catch {
                    debugPrint("AsyncNetworkService encountered an error: \(error)")
                }
                
            } else if endpoint.authentication == .bearer {
                
                do {
                    guard let bearer: String = await self.credentialsService.getCredential(type: .bearer) else { throw AuthenticationError.missingBearer }
                    request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
                } catch {
                    
                }
                
            } else if endpoint.authentication == .basic {
                
                do {
                    guard let username: String = await self.credentialsService.getCredential(type: .bearer) else { throw AuthenticationError.missingUsername }
                    guard let password: String = await self.credentialsService.getCredential(type: .bearer) else { throw AuthenticationError.missingPassword }
                    
                    let raw = String(format: "%@:%@", username, password)
                    let data = raw.data(using: .utf8)!
                    let encoded = data.base64EncodedString()
                    request.addValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
                    
                } catch {
                    debugPrint("AsyncNetworkService encountered an error: \(error)")
                }
                                
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let urlResponse = response as? HTTPURLResponse else {
                debugPrint("AsyncNetworkService encountered an error: invalidResponseType")
                throw NetworkServiceTypeError.invalidResponseType(response, data)
            }
            
            guard urlResponse.statusCode != 204 else {
                guard let reply = EmptyReply() as? T else {
                    debugPrint("AsyncNetworkService encountered an error: invalidResponseType")
                    throw NetworkServiceTypeError.invalidResponseType(response, data)
                }
                return reply
            }
            
            guard urlResponse.statusCode < 400 else {
                
                if urlResponse.statusCode == 401 {
                    if retries >= 1 {
                        await self.credentialsService.invalidate()
                        return try await self.send(endpoint: endpoint, using: decoder, retries: retries - 1)
                    } else {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .logOut, object: nil)
                        }
                        debugPrint("AsyncNetworkService encountered an error: unauthorized")
                        throw NetworkServiceTypeError.unauthorized(data: data)
                    }
                } else {
                    debugPrint("AsyncNetworkService encountered an error: unSuccessful")
                    throw NetworkServiceTypeError.unSuccessful(urlResponse, data, urlResponse.statusCode, nil)
                }
            }
            
            do {
                // The response might not have any data instead of an empty dictionary
                if let reply = EmptyReply() as? T { return reply }

                let model: T = try decoder.decode(T.self, from: data)
                return model
            } catch let error {
                debugPrint("AsyncNetworkService encountered an error: \(error) ")
                throw NetworkServiceTypeError.decodingError(urlResponse, data, error)
            }
        } /*catch let error as NetworkServiceTypeError {
            switch error {
                case .decodingError(_, let data, _), .invalidResponseType(_, let data), .unSuccessful(_, let data, _, _), .unauthorized(let data):
                    guard let data = data else { throw error }
                    guard let response = try? decoder.decode(ErrorResponse.self, from: data) else { throw error }
                    throw response
            }
        } */ catch {
            debugPrint("AsyncNetworkService encountered an error: \(error)")
            throw error
        }
        
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

public extension NSNotification.Name {
    
    static let logOut = NSNotification.Name("logOut")
    
}

public extension String {
    
    static let errorKey = NSNotification.Name("errorKey")
    
}
