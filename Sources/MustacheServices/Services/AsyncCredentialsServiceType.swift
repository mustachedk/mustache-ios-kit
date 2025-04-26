import Foundation
import MustacheFoundation

@available(iOS 13.0, macOS 15, *)
public protocol AsyncCredentialsServiceType: Actor {
    
    static var accessibility: KeychainItemAccessibility { get set }
    
    init()
    
    func getCredential<T: Credential> (type: CredentialType) async -> T?
    
    func setCredential(type: CredentialType, value: Credential?) async
    
    func invalidate(type: CredentialType) async
    
    func invalidate() async
    
    func clearState() async
    
}

@available(iOS 13.0, macOS 15, *)
public actor AsyncCredentialsService: AsyncCredentialsServiceType {
    
    public static var accessibility: KeychainItemAccessibility = .afterFirstUnlock
    
    @KeychainOptional(CredentialType.username.rawValue, accessibility: AsyncCredentialsService.accessibility)
    var username: String?
    
    @KeychainOptional(CredentialType.password.rawValue, accessibility: AsyncCredentialsService.accessibility)
    var password: String?
    
    @KeychainOptional(CredentialType.bearer.rawValue, accessibility: AsyncCredentialsService.accessibility)
    var bearer: String?
    
    @KeychainOptional(CredentialType.oauth.rawValue, accessibility: AsyncCredentialsService.accessibility)
    var oauthToken: AuthToken?
    
    public init() { }
    
    public func getCredential<T: Credential> (type: CredentialType) async -> T? {
        
        switch type {
            case .username:
                return self.username as? T
            case .password:
                return self.password as? T
            case .bearer:
                return self.bearer as? T
            case .oauth:
                return self.oauthToken as? T
        }
    }
    
    public func setCredential(type: CredentialType, value: Credential?) async {
        switch (type, value) {
            case (.username, let value as String):
                self.username = value
            case (.username, .none):
                self.username = nil
                
            case (.password, let value as String):
                self.password = value
            case (.password, .none):
                self.password = nil
            
            case (.bearer, let value as String):
                self.bearer = value
            case (.bearer, .none):
                self.bearer = nil
            
            case (.oauth, let value as AuthToken):
                self.oauthToken = value
            case (.oauth, .none):
                self.oauthToken = nil
            
            default:
                break
        }
    }
    
    public func invalidate(type: CredentialType) async {
        switch type {
            case .username ,.password, .bearer:
                for accessibility in KeychainItemAccessibility.allCases {
                    KeychainWrapper.standard.removeObject(forKey: type.rawValue, withAccessibility: accessibility)
                }
            case .oauth:
                guard let old = self.oauthToken else { return }
                for accessibility in KeychainItemAccessibility.allCases {
                    KeychainWrapper.standard.removeObject(forKey: CredentialType.oauth.rawValue, withAccessibility: accessibility)
                }
                self.oauthToken = AuthToken(accessToken: "expired",
                                             accessTokenExpiration: Date.distantPast,
                                             refreshToken: old.refreshToken)
        }
        
    }
    
    public func invalidate() async {
        for type in CredentialType.allCases {
            await self.invalidate(type: type)
        }
        
    }
    
    public func clearState() async {
        
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialType.username.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialType.password.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialType.bearer.rawValue, withAccessibility: accessibility)
        }
        for accessibility in KeychainItemAccessibility.allCases {
            KeychainWrapper.standard.removeObject(forKey: CredentialType.oauth.rawValue, withAccessibility: accessibility)
        }
        
    }
    
}

public protocol Credential: Codable {}

extension String: Credential {}

extension AuthToken: Credential {}

public enum CredentialType: String, CaseIterable {
    
    case username
    case password
    case bearer
    case oauth
    
}
