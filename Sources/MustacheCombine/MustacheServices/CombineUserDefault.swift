
import Foundation
import Combine

// Credit
// https://gist.github.com/simonbs/61c8269e1b0550feab606ee9890fa72b

@propertyWrapper
public class UserDefaultC<T: Codable>: NSObject {
    
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
        }
    }

    public var projectedValue: AnyPublisher<T, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    private let key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T, Never>
    
    public init(_ key: String, defaultValue: T , userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(defaultValue)
        super.init()
        self.userDefaults.register(defaults: [key: defaultValue])
        self.userDefaults.addObserver(self, forKeyPath: self.key, options: .new, context: &observerContext)
        self.subject.value = defaultValue
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if context == &observerContext {
                self.subject.value = self.wrappedValue
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
    }
    
    deinit {
        self.userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}

@propertyWrapper
public  class UserDefaultCOptional<T: Codable>: NSObject {
    
    public var wrappedValue: T? {
        get {
            guard let data = self.userDefaults.data(forKey: self.key) else { return nil }
            guard let item = try? JSONDecoder().decode(T.self, from: data) else { return nil }
            return item
        }
        set {
            if let newValue, let encoded: Data = try? JSONEncoder().encode(newValue) {
                self.userDefaults.set(encoded, forKey: self.key)
            }
        }
    }
    
    public var projectedValue: AnyPublisher<T?, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    private let key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T?, Never>
    
    public init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(nil)
        super.init()
        self.userDefaults.addObserver(self, forKeyPath: self.key, options: .new, context: &observerContext)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            self.subject.value = self.wrappedValue
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        self.userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}
