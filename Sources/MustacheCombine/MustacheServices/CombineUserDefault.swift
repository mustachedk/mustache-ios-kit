
import Foundation
import Combine

// Credit
// https://gist.github.com/simonbs/61c8269e1b0550feab606ee9890fa72b

@available(iOS 13.0, *)
public typealias UserDefaultC = UserDefaultCombine

@available(iOS 13.0, *)
@propertyWrapper
public class UserDefaultCombine<T: Codable>: NSObject {
    
    public var wrappedValue: T {
        get {
            guard let data = self.userDefaults.data(forKey: self.key) else { return self.subject.value }
            guard let item = try? JSONDecoder().decode(T.self, from: data) else { return self.subject.value }
            return item
        }
        set {
            if let encoded: Data = try? JSONEncoder().encode(newValue) {
                self.userDefaults.set(encoded, forKey: self.key)
            }
            NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
        }
    }

    public var projectedValue: AnyPublisher<T, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    private let key: String
    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<T, Never>
    private var localeChangeObserver: NSObjectProtocol!
    
    public init(_ key: String, defaultValue: T , userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(defaultValue)
        super.init()
        self.localeChangeObserver = NotificationCenter.default.addObserver(forName: notificationName(key: key),
                                                                           object: nil,
                                                                           queue: .main) { [unowned self] _ in
            self.subject.value = self.wrappedValue
        }
        self.subject.value = self.wrappedValue        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.localeChangeObserver as Any)
    }
    
}

@available(iOS 13.0, *)
public typealias UserDefaultCOptional = UserDefaultCombineOptional

@available(iOS 13.0, *)
@propertyWrapper
public class UserDefaultCombineOptional<T: Codable>: NSObject {
    
    public var wrappedValue: T? {
        get {
            guard let data = self.userDefaults.data(forKey: self.key) else { return nil }
            guard let item = try? JSONDecoder().decode(T.self, from: data) else { return nil }
            return item
        }
        set {
            if let newValue, let encoded: Data = try? JSONEncoder().encode(newValue) {
                self.userDefaults.set(encoded, forKey: self.key)
            } else {
                self.userDefaults.removeObject(forKey: self.key)
            }
            NotificationCenter.default.post(name: notificationName(key: self.key), object: nil)
        }
    }
    
    public var projectedValue: AnyPublisher<T?, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    private let key: String
    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<T?, Never>
    private var localeChangeObserver: NSObjectProtocol!
    
    public init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(nil)
        super.init()
        self.localeChangeObserver = NotificationCenter.default.addObserver(forName: notificationName(key: key),
                                                                           object: nil,
                                                                           queue: .main) { [unowned self] _ in
            self.subject.value = self.wrappedValue
        }
        self.subject.value = self.wrappedValue
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self.localeChangeObserver as Any)
    }
}

func notificationName(key: String) -> NSNotification.Name {
    let rawValue = "\(UserDefaults.didChangeNotification)-\(key)"
    let notificationName = NSNotification.Name(rawValue: rawValue)
    return notificationName
}
