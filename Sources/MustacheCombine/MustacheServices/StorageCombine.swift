import Foundation
import MustacheFoundation
import Combine

// MARK: - Thread-Safe Storage Implementation

/// A thread-safe property wrapper that provides storage with Combine publishers
@available(iOS 13.0, macOS 10.15, *)
@propertyWrapper
public class StorageCombine<T: Codable>: NSObject {
    
    // MARK: - Public API
    
    public var wrappedValue: T? {
        get { storage.getValue() }
        set { storage.setValue(newValue) }
    }
    
    public var projectedValue: AnyPublisher<T?, Never> {
        storage.publisher
    }
    
    // MARK: - Private Implementation
    
    private let storage: StorageBackend<T>
    
    // MARK: - Initialization
    
    public init(_ key: String, mode: StorageMode, defaultValue: T? = nil, expiration: ExpirationType = .none) {
        self.storage = StorageBackend(key: key, mode: mode, defaultValue: defaultValue, expiration: expiration)
        super.init()
    }
}

/// Non-optional variant with default value
@available(iOS 13.0, macOS 10.15, *)
@propertyWrapper
public class StorageCombineDefault<T: Codable>: NSObject {
    
    public var wrappedValue: T {
        get { self.storage.getValue() ?? defaultValue }
        set { self.storage.setValue(newValue) }
    }
    
    public var projectedValue: AnyPublisher<T, Never> {
        self.storage.publisher
            .map { [weak self] value in
                value ?? self?.defaultValue
            }
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    private let storage: StorageBackend<T>
    private let defaultValue: T
    
    public init(_ key: String, mode: StorageMode, defaultValue: T, expiration: ExpirationType = .none) {
        self.storage = StorageBackend(key: key, mode: mode, defaultValue: defaultValue, expiration: expiration)
        self.defaultValue = defaultValue
        super.init()
    }
}

// MARK: - Publisher Center

@available(iOS 13.0, macOS 10.15, *)
private class PublisherCenter {
    static let shared = PublisherCenter()
    private init() {}

    private var publishers: [StorageIdentifier: Any] = [:]
    private let lock = NSLock()

    func publisher<T: Codable>(for identifier: StorageIdentifier, initialValueProvider: () -> T?) -> CurrentValueSubject<T?, Never> {
        lock.lock()
        defer { lock.unlock() }

        if let existingPublisher = publishers[identifier] as? CurrentValueSubject<T?, Never> {
            return existingPublisher
        }
        
        let value = initialValueProvider()
        let newPublisher = CurrentValueSubject<T?, Never>(value)
        publishers[identifier] = newPublisher
        return newPublisher
    }
}

private struct StorageIdentifier: Hashable {
    let key: String
    let mode: StorageMode
}


// MARK: - Storage Backend

@available(iOS 13.0, macOS 10.15, *)
private class StorageBackend<T: Codable> {
    
    private let key: String
    private let mode: StorageMode
    private let expiration: ExpirationType
    
    private let subject: CurrentValueSubject<T?, Never>
    private let lock = NSLock()
    
    // For unique memory scope, store the value in the instance
    private var uniqueMemoryStorage: CacheContainer<T>?
    
    var publisher: AnyPublisher<T?, Never> {
        self.subject.eraseToAnyPublisher()
    }
    
    init(key: String, mode: StorageMode, defaultValue: T?, expiration: ExpirationType) {
        self.key = key
        self.mode = mode
        self.expiration = expiration
        
        if case .memory(let scope) = mode, scope == .unique {
            // Unique scope does not share publishers. Each instance is independent.
            // It starts empty, only populated by the default value if provided.
            if let defaultValue = defaultValue {
                self.uniqueMemoryStorage = CacheContainer(value: defaultValue, createdAt: Date())
            }
            self.subject = CurrentValueSubject(defaultValue)
        } else {
            // For all shared modes, use the PublisherCenter to get a shared publisher.
            let identifier = StorageIdentifier(key: key, mode: mode)
            self.subject = PublisherCenter.shared.publisher(for: identifier) {
                // This closure is only executed once when the publisher is first created
                // for a given identifier. It reads the initial value from storage
                // and sets the default value if storage is empty.
                let existing = Self.readFromStorage(key: key, mode: mode, expiration: expiration)
                
                if let existing = existing {
                    return existing
                }
                
                if let defaultValue = defaultValue {
                    Self.writeToStorage(key: key, mode: mode, value: defaultValue)
                    return defaultValue
                }
                
                return nil
            }
        }
    }
    
    func getValue() -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        // For unique scope, read from instance storage
        if case .memory(let scope) = mode, scope == .unique {
            guard let container = uniqueMemoryStorage else { return nil }
            
            // Check expiration
            guard Self.isValid(container: container, expiration: expiration) else {
                uniqueMemoryStorage = nil
                return nil
            }
            
            return container.value
        }
        
        return Self.readFromStorage(key: key, mode: mode, expiration: expiration)
    }
    
    func setValue(_ value: T?) {
        lock.lock()
        
        // For unique scope, write to instance storage
        if case .memory(let scope) = mode, scope == .unique {
            if let value = value {
                uniqueMemoryStorage = CacheContainer(value: value, createdAt: Date())
            } else {
                uniqueMemoryStorage = nil
            }
            
            let valueToSend = value
            lock.unlock()
            
            // Send update after releasing lock
            self.subject.send(valueToSend)
            return
        }
        
        if let value = value {
            Self.writeToStorage(key: self.key, mode: self.mode, value: value)
        } else {
            Self.clearStorage(key: self.key, mode: self.mode)
        }
        
        let valueToSend = value
        lock.unlock()
        
        // Send update after releasing lock to avoid potential deadlocks
        self.subject.send(valueToSend)
    }
    
    // MARK: - Storage Operations
    
    private static func readFromStorage(key: String, mode: StorageMode, expiration: ExpirationType) -> T? {
        let container: CacheContainer<T>?
        
        switch mode {
            case .userDefaults(let defaults):
                guard let data = defaults.data(forKey: key),
                      let decoded = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else {
                    return nil
                }
                container = decoded
                
            case .keychain(let accessibility):
                guard let data = KeychainWrapper.standard.data(forKey: key, withAccessibility: accessibility),
                      let decoded = try? JSONDecoder().decode(CacheContainer<T>.self, from: data) else {
                    return nil
                }
                container = decoded
                
            case .memory(let scope):
                container = MemoryStorage.shared.get(key: key, scope: scope)
        }
        
        guard let container = container else { return nil }
        
        // Check expiration
        guard isValid(container: container, expiration: expiration) else {
            clearStorage(key: key, mode: mode)
            return nil
        }
        
        return container.value
    }
    
    private static func writeToStorage(key: String, mode: StorageMode, value: T?) {
        guard let value = value else {
            self.clearStorage(key: key, mode: mode)
            return
        }
        
        let container = CacheContainer(value: value, createdAt: Date())
        
        switch mode {
            case .userDefaults(let defaults):
                if let data = try? JSONEncoder().encode(container) {
                    defaults.set(data, forKey: key)
                }
                
            case .keychain(let accessibility):
                if let data = try? JSONEncoder().encode(container) {
                    KeychainWrapper.standard.set(data, forKey: key, withAccessibility: accessibility)
                }
                
            case .memory(let scope):
                MemoryStorage.shared.set(key: key, scope: scope, value: container)
        }
    }
    
    private static func clearStorage(key: String, mode: StorageMode) {
        switch mode {
            case .userDefaults(let defaults):
                defaults.removeObject(forKey: key)
                
            case .keychain(let accessibility):
                KeychainWrapper.standard.removeObject(forKey: key, withAccessibility: accessibility)
                
            case .memory(let scope):
                MemoryStorage.shared.remove(key: key, scope: scope)
        }
    }
    
    private static func isValid(container: CacheContainer<T>, expiration: ExpirationType) -> Bool {
        switch expiration {
            case .none:
                return true
                
            case .seconds(let seconds):
                let expirationDate = container.createdAt.addingTimeInterval(seconds)
                return expirationDate > Date.nowSafe
                
            case .timestamp(let date):
                return date > Date.nowSafe
                
            case .dayOfWeek(let weekday):
                let components = DateComponents(calendar: Calendar.daDK, hour: 23, minute: 59, second: 59, weekday: weekday)
                if let expirationDate = Calendar.daDK.nextDate(after: container.createdAt, matching: components, matchingPolicy: .nextTime) {
                    return expirationDate > Date.nowSafe
                }
                return true
                
            case .hourOfDay(let hour):
                let components = DateComponents(calendar: Calendar.daDK, hour: hour, minute: 0, second: 0)
                if let expirationDate = Calendar.daDK.nextDate(after: container.createdAt, matching: components, matchingPolicy: .nextTime) {
                    return expirationDate > Date.nowSafe
                }
                return true
        }
    }
}

// MARK: - Thread-Safe Memory Storage

@available(iOS 13.0, macOS 10.15, *)
private class MemoryStorage {
    static let shared = MemoryStorage()
    
    private let lock = NSLock()
    private var singletonStorage: [String: Any] = [:]
    private var sharedStorage: NSMapTable<NSString, AnyObject> = .strongToStrongObjects()
    
    func get<T: Codable>(key: String, scope: MemoryScope) -> CacheContainer<T>? {
        lock.lock()
        defer { lock.unlock() }
        
        switch scope {
            case .singleton:
                return singletonStorage[key] as? CacheContainer<T>
            case .shared:
                return sharedStorage.object(forKey: key as NSString) as? CacheContainer<T>
            case .unique:
                return nil // Unique scope is handled inside StorageBackend
        }
    }
    
    func set<T: Codable>(key: String, scope: MemoryScope, value: CacheContainer<T>) {
        lock.lock()
        defer { lock.unlock() }
        
        switch scope {
            case .singleton:
                self.singletonStorage[key] = value
            case .shared:
                self.sharedStorage.setObject(value, forKey: key as NSString)
            case .unique:
                break // Unique scope is handled inside StorageBackend
        }
    }
    
    func remove(key: String, scope: MemoryScope) {
        lock.lock()
        defer { lock.unlock() }
        
        switch scope {
            case .singleton:
                self.singletonStorage[key] = nil
            case .shared:
                self.sharedStorage.removeObject(forKey: key as NSString)
            case .unique:
                break
        }
    }
}

// MARK: - Supporting Types

/// Container for cached values with creation timestamp
private class CacheContainer<T: Codable>: NSObject, Codable {
    let value: T
    let createdAt: Date
    
    init(value: T, createdAt: Date) {
        self.value = value
        self.createdAt = createdAt
    }
}

/// Storage mode configuration
public enum StorageMode: Hashable {
    case userDefaults(defaults: UserDefaults = .standard)
    case keychain(accessibility: KeychainItemAccessibility = .afterFirstUnlock)
    case memory(scope: MemoryScope = .shared)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .userDefaults(let defaults):
            hasher.combine("userDefaults")
            hasher.combine(defaults)
        case .keychain(let accessibility):
            hasher.combine("keychain")
            hasher.combine(accessibility)
        case .memory(let scope):
            hasher.combine("memory")
            hasher.combine(scope)
        }
    }

    public static func == (lhs: StorageMode, rhs: StorageMode) -> Bool {
        switch (lhs, rhs) {
        case (.userDefaults(let l), .userDefaults(let r)):
            return l == r
        case (.keychain(let l), .keychain(let r)):
            return l == r
        case (.memory(let l), .memory(let r)):
            return l == r
        default:
            return false
        }
    }
}

/// Memory storage scope
public enum MemoryScope: Hashable {
    case shared      // Shared across app, deallocated when no longer referenced
    case singleton   // Persists for app lifetime
    case unique      // Each instance is independent
}

/// Expiration configuration
public enum ExpirationType {
    case none
    case seconds(TimeInterval)
    case timestamp(Date)
    case dayOfWeek(Int)
    case hourOfDay(Int)
}

