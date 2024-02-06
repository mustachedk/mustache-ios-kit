
import Foundation
import MustacheFoundation
import Resolver
import LocalAuthentication

public protocol SecureStorageServiceType {
    
    var passcodeSet: Bool { get }
    
    var biometricsEnabled: Bool { get }
    
    var isBiometricsLocked: Bool { get }
    
    var isFaceIdSupported: Bool { get }
    
    var isTouchIdSupported: Bool { get }
    
    var dataStoredWithPin: Bool { get }
    
    var dataStoredWithBiometry: Bool { get }
    
    func store(data: Data, with pin: String) throws
    
    @available(iOS 13.0, macOS 15, *)
    func enableBiometrics() async throws
    
    func store(data: Data) throws
    
    @available(iOS 13.0, macOS 15, *)
    func getData(with pin: String) async throws -> Data
    
    @available(iOS 13.0, macOS 15, *)
    func getData() async throws -> Data
    
    func clearData(from: UIDStorageMode)
    
    func reset()
    
}

public class SecureStorageService: SecureStorageServiceType {
    
    public var passcodeSet: Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return error?.code != LAError.passcodeNotSet.rawValue
    }
    
    public var biometricsEnabled: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public var isBiometricsLocked: Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return error?.code == LAError.biometryLockout.rawValue
    }
    
    public var isFaceIdSupported: Bool {
        let context = LAContext()
        if #available(macOS 10.15, *) {
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .faceID
        } else {
            return false
        }
    }
    
    public var isTouchIdSupported: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .touchID
    }
    
    public var dataStoredWithPin: Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.secAttrService,
            kSecAttrAccount: "\(UIDStorageMode.pin.rawValue)",
            kSecUseAuthenticationContext: context
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecInteractionNotAllowed
    }
    
    public var dataStoredWithBiometry: Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.secAttrService,
            kSecAttrAccount: "\(UIDStorageMode.biometric.rawValue)",
            kSecUseAuthenticationContext: context
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecInteractionNotAllowed // Second option is if biometrics have been locked due to many attempts
    }
    
    private var pinAttempts: Int {
        get {
            guard let data = KeychainWrapper.standard.data(forKey: "pinAttempts", withAccessibility: .afterFirstUnlockThisDeviceOnly) else { return 0 }
            let attempts = data.withUnsafeBytes( { $0.load(as: Int.self) })
            return attempts
        }
        set {
            let data = withUnsafeBytes(of: newValue) { Data($0) }
            KeychainWrapper.standard.set(data, forKey: "pinAttempts", withAccessibility: .afterFirstUnlockThisDeviceOnly)
        }
    }
    
    private var localizedReason: String {
        let localizedReason = "biometric_login".localized
        return localizedReason
    }
    
    @Injected(name: .maxPinAttempt)
    private var maxPinAttempts: Int
    
    private var key: String
    
    private var secAttrService: String {
        "SecureStorageService.service-\(self.key)"
    }
    
    public init(key: String = "Data") {
        self.key = key
        self.configure()
    }
    
    private func configure() { }
    
    public func store(data: Data, with pin: String) throws {
            
        var query = self.queryFor(mode: .pin, accessControl: self.accessControl(flags: [.applicationPassword]), context: self.context(pin: pin))
        
        query[kSecValueData] = data as Any
        
        var result: AnyObject?
        var status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            
            status = SecItemDelete(self.queryFor(mode: .pin) as CFDictionary)
            
            var replaceQuery = self.queryFor(mode: .pin, accessControl: self.accessControl(flags: [.applicationPassword]), context: self.context(pin: pin))
            replaceQuery[kSecValueData] = data as Any
            
            status = SecItemAdd(replaceQuery as CFDictionary, &result)
        }
        
        guard status == errSecSuccess else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
            
        }
            
    }
    @available(iOS 13.0, macOS 15, *)
    public func enableBiometrics() async throws {
        
        let context = LAContext()
        let result = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.localizedReason)
        if !result { throw SecureStorageError.biometricsNotEnabled }
        
    }
    
    public func store(data: Data) throws {
        
        var query = self.queryFor(mode: .biometric, accessControl: self.accessControl(flags: [.biometryAny]))
        
        query[kSecValueData] = data as Any
        
        var result: AnyObject?
        var status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            let searchQuery = self.queryFor(mode: .biometric)
            status = SecItemDelete(searchQuery as CFDictionary)
            
            status = SecItemAdd(query as CFDictionary, &result)
        }
        
        guard status == errSecSuccess else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
        }
            
    }
    
    public func getData(with pin: String) throws -> Data  {
        let context = self.context(pin: pin)
        context.interactionNotAllowed = true
        
        var searchQuery = self.queryFor(mode: .pin, context: context)
        searchQuery[kSecReturnData] = kCFBooleanTrue as Any
        
        var searchResult: AnyObject?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &searchResult)
        
        if status == errSecSuccess, let data = searchResult as? Data {
            self.pinAttempts = 0
            return data
        } else if status == errSecAuthFailed || status == errSecInteractionNotAllowed {
            var attempts = self.pinAttempts
            attempts += 1
            if attempts >= 10 {
                self.clearData(from: .pin)
                self.clearData(from: .biometric)
                self.pinAttempts = 0
                throw SecureStorageError.toManyAttempts
            } else {
                self.pinAttempts = attempts
            }
            throw SecureStorageError.pinNotMatched
        } else {
            // po SecCopyErrorMessageString(status, nil)
            throw SecureStorageError.unhandled
        }
        
    }
    
    @available(iOS 13.0, macOS 15, *)
    public func getData() async throws -> Data {
        
        let context = LAContext()
        // https://stackoverflow.com/questions/28108232/secitemcopymatching-for-touch-id-without-passcode-fallback
        // Not allowed
        // context.localizedFallbackTitle = Strings.Localizable.shoppingLocalAuthenticationFallBackMessage
        do {
            let _ =  try await context.evaluateAccessControl(self.accessControl(flags: [.biometryAny])!,
                                                                  operation: .useItem, localizedReason: self.localizedReason)
            var query = self.queryFor(mode: .biometric, accessControl: self.accessControl(flags: [.biometryAny]), context: context)
            query[kSecReturnData] = kCFBooleanTrue as Any
            query[kSecMatchLimit] = kSecMatchLimitOne
            query[kSecUseAuthenticationUI] = kSecUseAuthenticationUISkip
            
            var searchResult: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &searchResult)
            
            if status == errSecSuccess, let data = searchResult as? Data {
                return data
            } else {
                // po SecCopyErrorMessageString(status, nil)
                throw SecureStorageError.unhandled
            }
        } catch {
            if let error = error as? LAError {
                switch error.code {
                    case .userCancel:
                        throw SecureStorageError.userCancelled
                    case .biometryLockout:
                        throw SecureStorageError.biometricsLocked
                    case .biometryNotAvailable:
                        throw SecureStorageError.userCancelled
                    default:
                        throw error
                }
                
            } else {
                throw error
            }
        }
        
    }
    
    public func clearData(from mode: UIDStorageMode) {
        let _ = SecItemDelete(self.queryFor(mode: mode) as CFDictionary)
    }
    
    public func reset() {
        self.clearData(from: .pin)
        self.clearData(from: .biometric)
        self.pinAttempts = 0
    }
        
    private func context(pin: String) -> LAContext {
        let context = LAContext()
        context.localizedReason = self.localizedReason
        context.setCredential(pin.data(using: .utf8), type: LACredentialType.applicationPassword)
        return context
    }
    
    private func accessControl(flags: SecAccessControlCreateFlags) -> SecAccessControl? {
        var accessError: Unmanaged<CFError>?
        let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags, &accessError)
        return access
    }
    
    private func queryFor(mode: UIDStorageMode, accessControl: SecAccessControl? = nil, context: LAContext? = nil) -> [CFString: Any] {
        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: self.secAttrService,
                                kSecAttrAccount: "\(mode.rawValue)"]
        
        if let accessControl = accessControl {
            query[kSecAttrAccessControl] = accessControl
        }
        if let context = context {
            query[kSecUseAuthenticationContext] = context
        }
        return query
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
}

public class SimulatorSecureStorageService: SecureStorageService {
    
    @UserDefault("SimulatorSecureStorageService.storage", defaultValue: [:])
    private var storage: [UIDStorageMode: Data]
    
    override public var dataStoredWithPin: Bool {
        return self.storage[.pin].exists
    }
    
    override public var dataStoredWithBiometry: Bool {
        return self.storage[.biometric].exists
    }
    
    override public init(key: String) {
        super.init(key: key)
    }
    
    override public func store(data: Data, with pin: String) throws {
        var storage = self.storage
        storage[.pin] = data
        self.storage = storage
    }
    
    override public func store(data: Data) throws {
        var storage = self.storage
        storage[.biometric] = data
        self.storage = storage
    }
    
    override public func getData(with pin: String) throws -> Data  {
        return self.storage[.pin] ?? Data()
    }
    
    @available(iOS 13.0, macOS 15, *)
    override public func getData() async throws -> Data {
        return self.storage[.biometric] ?? Data()
    }
    
    override public func clearData(from mode: UIDStorageMode) {
        var storage = self.storage
        storage[mode] = nil
        self.storage = storage
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SecureStorageService {
    
    static let service: String = "SecureStorageService.Service"
    
}

public extension Resolver.Name {
    
    static let maxPinAttempt = Resolver.Name("\(#file)-\(#function)")
    
}

public enum UIDStorageMode: String, Codable {
    case pin
    case biometric
}

public enum SecureStorageError: Error {
    case uncodable, userCancelled, biometricsNotEnabled, biometricsLocked, unhandled, toManyAttempts, pinNotMatched
}
