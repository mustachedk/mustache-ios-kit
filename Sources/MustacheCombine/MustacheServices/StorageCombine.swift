
import Foundation
import MustacheFoundation
import Combine
import Resolver

private var singletonMemoryContainer: [String: Any] = [:]
private var sharedMemoryKeyContainer = NSHashTable<NSString>.weakObjects()
private var sharedMemoryValueContainer = NSMapTable<NSString, AnyObject>.weakToStrongObjects()

@available(iOS 13.0, *)
@propertyWrapper
public class StorageCombine<T: Codable>: NSObject {
    
    public var wrappedValue: T? {
        get {
            switch self.mode {
                case .userDefaults(let defaults):
                    return self.getUserDefaults(defaults: defaults)
                case .keychain(let accessibility):
                    return self.getKeychain(accessibility: accessibility)
                case .memory(let scope):
                    return self.getMemory(scope: scope)
            }

        }
        set {
            switch self.mode {
                case .userDefaults(let defaults):
                    self.setUserDefaults(defaults: defaults, value: newValue)
                case .keychain(let accessibility):
                    self.setKeychain(accessibility: accessibility, value: newValue)
                case .memory(let scope):
                    self.setMemory(scope: scope, value: newValue)
            }
        }
    }
    
    // MARK: Configuraation
    
    private let key: String
    private let mode: StorageMode
    private let expiration: ExpirationType
    
    // MARK: Combine
    
    private var subject: CurrentValueSubject<T?, Never>
    private var localeChangeObserver: NSObjectProtocol!
    
    // MARK: Helpers
    
    private let valueUserInfoKey: String = "StorageCombine-valueUserInfoKey"
    
    // MARK: propertyWrapper variables
    
    public var projectedValue: AnyPublisher<T?, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    public init(_ key: String, mode: StorageMode, defaultValue: T? = nil, expiration: ExpirationType = .none) {
        self.key = key
        self.mode = mode
        self.expiration = expiration
        self.subject = CurrentValueSubject(defaultValue)
        
        super.init()
        
        self.configurePublisher()
        self.configureInitialValue(defaultValue: defaultValue)
        self.configureInMemory()
    }
    
    convenience init(_ key: String, mode: StorageMode, defaultValue: T? = nil, cacheExpiration: Double? = nil) {
        let expiration = cacheExpiration.exists ? ExpirationType.seconds(cacheExpiration!) : .none
        self.init(key, mode: mode, defaultValue: defaultValue, expiration: expiration)
    }
    
    func configurePublisher() {
        
        let object: Any? = switch mode {
            case .memory(let scope) where scope == .unique:
                self
            default:
                nil
        }
        
        self.localeChangeObserver = NotificationCenter.default.addObserver(forName: notificationName(key: self.key),
                                                                           object: object,
                                                                           queue: .main) { [unowned self] notification in
            
            // Sets the value and sends an event downstream
            let value = notification.userInfo?[self.valueUserInfoKey] as? T
            self.subject.value = value
            
        }
    }
    
    func configureInitialValue(defaultValue: T?) {
        if let defaultValue, self.wrappedValue == nil {
            // Sets the initial default value and sends an event downstream if no other value is previuosly stored
            self.wrappedValue = defaultValue
        } else if let wrappedValue = self.wrappedValue {
            // Sends an event if the initial value is present
            self.wrappedValue = wrappedValue
        } else {
            // Sends an event with an empty value
            self.wrappedValue = nil
        }
    }
    
    func configureInMemory() {
        
        guard case .memory(let scope) = self.mode, scope == .shared else { return }
        
        if let sharedKey = sharedMemoryKeyContainer.allObjects
            .compactMap({ $0 })
            .first(where: { $0.isEqual(to: self.key) }){
            self.sharedMemoryKey = sharedKey
        } else {
            let sharedMemoryKey = NSString(string: self.key)
            sharedMemoryKeyContainer.add(sharedMemoryKey)
            self.sharedMemoryKey = sharedMemoryKey
        }
    }
    
    private func isStillValid(cachedAt: Date) -> Bool {
        
        switch self.expiration {
            case .none:
                return true
                
            case .seconds(let seconds):
                let expirationTime = cachedAt.addingTimeInterval(seconds)
                if expirationTime < .nowSafe {
                    return false
                }
            case .dayOfWeek(let dayOfWeek):
                
                let components = DateComponents(calendar: Calendar.daDK, hour: 23, minute: 59, second: 59, weekday: dayOfWeek)
                let expirationTime = Calendar.daDK.nextDate(after: cachedAt,
                                                            matching: components,
                                                            matchingPolicy: .nextTime)
                
                if let expirationTime, expirationTime < .nowSafe {
                    return false
                }
                
            case .hourOfDay(let hourOfDay):
                
                let components = DateComponents(calendar: Calendar.daDK, hour: hourOfDay, minute: 0, second: 0)
                let expirationTime = Calendar.daDK.nextDate(after: cachedAt,
                                                            matching: components,
                                                            matchingPolicy: .nextTime)
                
                if let expirationTime, expirationTime < .nowSafe {
                    return false
                }
                
            case .timestamp(let expirationTime):
                
                if expirationTime < .nowSafe {
                    return false
                }
        }
        return true
    }
    
    private func clear() {
        
        switch self.mode {
            case .userDefaults(let defaults):
                defaults.removeObject(forKey: self.key)
            case .keychain(let accessibility):
                KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
            case .memory(let scope):
                switch scope {
                    case .singleton:
                        let key = String(describing: T.self)
                        singletonMemoryContainer[key] = nil
                    case .unique:
                        self.uniqueMemoryStorage = nil
                    case .shared:
                        sharedMemoryValueContainer.removeObject(forKey: self.sharedMemoryKey)
                }
        }
        NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
    }
    
    // MARK: StorageMode.userDefaults
    
    // MARK: StorageMode.keychain
    
    // MARK: StorageMode.memory
    
    private var uniqueMemoryStorage: CacheContainer<T>? = nil
    private var sharedMemoryKey: NSString? = nil
    
    // MARK: Lifecycle deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self.localeChangeObserver as Any)
    }
    
}



// MARK: StorageMode.userDefaults
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getUserDefaults(defaults: UserDefaults) -> T? {
        
        guard let data = defaults.data(forKey: self.key) else { return nil }
        
        guard let cache = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else { return nil }
        
        guard self.isStillValid(cachedAt: cache.createdAt) else {
            self.clear()
            return nil
        }
        
        return cache.value
    }
    
    func setUserDefaults(defaults: UserDefaults, value: T?, createdAt: Date = .nowSafe) {
        if let value = value {
            let cache = CacheContainer(value: value, createdAt: Date())
            if let encoded: Data = try? JSONEncoder().encode(cache) {
                /// Store object
                defaults.set(encoded, forKey: self.key)
            }
        } else {
            defaults.removeObject(forKey: self.key)
        }
        
        // Sends notification so that subscribers of CurrentValueSubject gets the newest object
        NotificationCenter.default.post(name: notificationName(key: self.key),
                                        object: nil,
                                        userInfo: [self.valueUserInfoKey: value as Any])
    }
    
}
// MARK: StorageMode.keychain
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getKeychain(accessibility: KeychainItemAccessibility) -> T? {
        
        guard let data = KeychainWrapper.standard.data(forKey: self.key, withAccessibility: accessibility) else { return nil }
        
        guard let cache = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else { return nil }
        
        guard self.isStillValid(cachedAt: cache.createdAt) else {
            self.clear()
            return nil
        }
        
        return cache.value
    }
    
    func setKeychain(accessibility: KeychainItemAccessibility, value: T?) {
        
        if let value = value {
            let cache = CacheContainer(value: value, createdAt: Date())
            if let encoded: Data = try? JSONEncoder().encode(cache) {
                
                /// Store object
                KeychainWrapper.standard.set(encoded, forKey: self.key)
                
            }
        } else {
            KeychainWrapper.standard.removeObject(forKey: self.key, withAccessibility: accessibility)
        }
        
        // Sends notification so that subscribers of CurrentValueSubject gets the newest object
        NotificationCenter.default.post(name: notificationName(key: self.key),
                                        object: nil,
                                        userInfo: [self.valueUserInfoKey: value as Any])
    }
    
}

// MARK: StorageMode.memory
@available(iOS 13.0, *)
extension StorageCombine {
    
    func getMemory(scope: MemoryScope) -> T? {
        switch scope {
            case .singleton:
            
                guard let cache = singletonMemoryContainer[self.key] as? CacheContainer<T?>, let value = cache.value else { return nil }
                
                /// Object has expired, so we remove it from the cache
                guard self.isStillValid(cachedAt: cache.createdAt) else {
                    self.clear()
                    return nil
                }
                
                return cache.value
                
            case .unique:
                
                guard let cache = self.uniqueMemoryStorage else { return nil }
                
                guard self.isStillValid(cachedAt: cache.createdAt) else {
                    self.clear()
                    return nil
                }
                
                return cache.value
                
            case .shared:

                guard let cache = sharedMemoryValueContainer.object(forKey: self.sharedMemoryKey) as? CacheContainer<T> else { return nil }
                
                guard self.isStillValid(cachedAt: cache.createdAt) else {
                    self.clear()
                    return nil
                }
                
                return cache.value
        }
    }
    
    func setMemory(scope: MemoryScope, value: T?) {
        switch scope {
            case .singleton:
                
                let cache = CacheContainer(value: value, createdAt: Date())
                singletonMemoryContainer[self.key] = cache
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: nil,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
            case .unique:
                
                if let value = value {
                    let cache = CacheContainer(value: value, createdAt: Date())
                    self.uniqueMemoryStorage = cache
                } else {
                    self.uniqueMemoryStorage = nil
                }
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: self,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
            case .shared:
                
                if let value = value {
                    let cache = CacheContainer(value: value, createdAt: Date())
                    sharedMemoryValueContainer.setObject(cache, forKey: self.sharedMemoryKey)
                } else {
                    sharedMemoryValueContainer.removeObject(forKey: self.sharedMemoryKey)
                }
                
                // Sends notification so that subscribers of CurrentValueSubject gets the newest object
                NotificationCenter.default.post(name: notificationName(key: self.key),
                                                object: self,
                                                userInfo: [self.valueUserInfoKey: value as Any])
                
                
        }
    }
    
}

/// Defines the storage mode to be used
public enum StorageMode {
    
    /// Uses UserDefaults, uses standard if not specified.
    case userDefaults(defaults: UserDefaults = .standard)
    
    /// Uses Keychain.
    case keychain(accessibility: KeychainItemAccessibility = .afterFirstUnlock)
    
    /// Uses Memory.
    case memory(scope: MemoryScope = .shared)
        
}

/// Defines the life cycle of the memory storage.
public enum MemoryScope {
    
    /// Shared acros the app, dealocated when no longer used, default if not specified.
    case shared
    
    /// Shared acros the apps lifetime, never deallocated unless app is killed
    case singleton
    
    /// Each instance is unique, same keys does not overwrite, not commenly used
    case unique
        
}

/// Defines the type of expiration used for the storage.
public enum ExpirationType {
    
    /// Seconds after setting the value
    case seconds(TimeInterval)
    
    /// After a day of the week has passed, e.g. 2 equals every monday, 1 equals sunday, based on Calendar Weekday
    case dayOfWeek(Int)
    
    /// After an hour of the day has passed, e.g. every day at 00:00, zero index based which means 0 is 00:00, 1 is 01:00 etc.
    case hourOfDay(Int)
    
    /// At a specific timestamp
    case timestamp(Date)
    
    case none
    
}

/// Container used to handle expiration of cached objects
private class CacheContainer<T: Codable>: Codable {
    
    var value: T
    var createdAt: Date
    
    init(value: T, createdAt: Date) {
        self.value = value
        self.createdAt = createdAt
    }
    
    static func < (lhs: CacheContainer, rhs: CacheContainer) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
}

public extension Double {
    
    static var minute: Double { 60 }
    
    static var hour: Double { .minute * 60 }
    
    static var day: Double { .hour * 24 }
    
    static var week: Double { .day * 7 }
    
}
