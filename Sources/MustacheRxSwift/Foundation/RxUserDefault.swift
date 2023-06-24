import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
open class RxUserDefault<Value: Codable> {
    
    var key: String
    
    fileprivate var defaultValue: Value
    
    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    open var wrappedValue: Value {
        get { UserDefaults.standard.decodeObject(forKey: key) ?? self.defaultValue }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
    
    open var projectedValue: Observable<Value> {
        return UserDefaults.standard.observeCodable(Value.self, self.key).unwrap().startWith(self.wrappedValue)
    }
}

@propertyWrapper
open class RxUserDefaultOptional<Value: Codable> {
    
    fileprivate var key: String
    
    public init(_ key: String) {
        self.key = key
    }
    
    open var wrappedValue: Value? {
        get { UserDefaults.standard.decodeObject(forKey: key) }
        set { UserDefaults.standard.encode(newValue, forKey: key) }
    }
    
    open var projectedValue: Observable<Value?> {
        return UserDefaults.standard.observeCodable(Value.self, self.key).startWith(self.wrappedValue)
    }
}
