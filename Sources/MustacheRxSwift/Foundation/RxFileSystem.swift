
import Foundation

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

@propertyWrapper
open class RxFileSystem<Value: Codable> {
    
    private var key: String
    private var defaultValue: Value
    
    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    open var wrappedValue: Value {
        get { FileManager.default.decodeObject(forKey: key) ?? self.defaultValue }
        set { FileManager.default.encode(newValue, forKey: key) }
    }
    
    open var projectedValue: RxObservable<Value> {
        return FileManager.default.observeCodable(Value.self, self.key).compactMap({ $0 }).startWith(self.wrappedValue)
    }
    
}

@propertyWrapper
open class RxFileSystemOptional<Value: Codable> {
    
    private var key: String
    
    public init(_ key: String) {
        self.key = key
    }
    
    open var wrappedValue: Value? {
        get { FileManager.default.decodeObject(forKey: key) }
        set { FileManager.default.encode(newValue, forKey: key) }
    }
    
    open var projectedValue: RxObservable<Value?> {
        return FileManager.default.observeCodable(Value.self, self.key).startWith(self.wrappedValue)
    }
    
}

#endif
