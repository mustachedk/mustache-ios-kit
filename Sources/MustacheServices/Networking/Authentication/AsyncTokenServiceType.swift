
import Foundation
import MustacheFoundation
import Resolver

@available(iOS 13.0, macOS 15, *)
public protocol AsyncTokenServiceType: Actor {
    
    init()
    
    func validToken() async throws -> AuthToken
    
    func refreshToken() async throws -> AuthToken
}

@available(iOS 13.0, macOS 15, *)
public actor AsyncTokenService: AsyncTokenServiceType {
    
    @Injected
    var credentialsService: AsyncCredentialsServiceType
    
    @LazyInjected
    var refreshTokenService: RefreshTokenServiceType
        
    var refreshTask: Task<AuthToken, Error>?
        
    public init() { }
    
    public func validToken() async throws -> AuthToken {
        
        if let handle = self.refreshTask {
            return try await handle.value
        }
        
        guard let token: AuthToken = await self.credentialsService.getCredential(type: .oauth) else {
            throw AuthenticationError.missingToken
        }
        
        if token.isValid {
            return token
        } else {
            return try await self.refreshToken()
        }
        
    }
    
    public func refreshToken() async throws -> AuthToken {
        
        if let refreshTask = self.refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> AuthToken in
            defer { self.refreshTask = nil }
            
            guard let oldToken: AuthToken = await self.credentialsService.getCredential(type: .oauth),
                  let refreshToken = oldToken.refreshToken else {
                throw AuthenticationError.missingRefreshToken
            }
            
            let endpoint = try self.refreshTokenService.endpoint(refreshToken: refreshToken)
            let request = endpoint.request()
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                await self.credentialsService.setCredential(type: .oauth, value: nil)
                throw AuthenticationError.refreshTokenExpired
            }
            
            let token = try self.refreshTokenService.token(for: data)
            
            await self.credentialsService.setCredential(type: .oauth, value: token)
            return token
            
        }
        
        self.refreshTask = task
        
        return try await task.value
        
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

public protocol RefreshTokenServiceType {
    
    func endpoint(refreshToken: String) throws -> Endpoint
    
    func token(for data: Data) throws -> AuthToken
}

//extension AsyncNetworkService: RefreshTokenServiceType {
//
//    nonisolated public func endpoint(refreshToken: String) throws -> Endpoint {
//        let request = AccessTokenRequest(refreshToken: refreshToken)
//        let endpoint = AuthenticationEndpoint.accessToken(request)
//        return endpoint
//    }
//
//    nonisolated public func token(for data: Data) throws -> AuthToken {
//        let authResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
//        let token = AuthToken(response: authResponse)
//        return token
//    }
//}
