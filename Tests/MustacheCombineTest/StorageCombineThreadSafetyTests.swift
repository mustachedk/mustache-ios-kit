import XCTest
import Combine
@testable import MustacheCombine

// Helper for iOS 13+ compatible sleep
extension Task where Success == Never, Failure == Never {
    static func sleep(milliseconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
    }
}

@available(iOS 13.0, macOS 10.15, *)
final class StorageCombineThreadSafetyTests: XCTestCase {
    
    // MARK: - Race Condition Tests
    
    func testConcurrentReads() async throws {
        let storage = StorageCombine<String>("test.concurrent.reads", mode: .memory(scope: .shared), expiration: .none)
        storage.wrappedValue = "initial value"
        
        // Wait for async write to complete
        try await Task.sleep(milliseconds: 100)
        
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    return storage.wrappedValue
                }
            }
            
            var results: [String?] = []
            for await result in group {
                results.append(result)
            }
            
            // All reads should succeed without crashing
            XCTAssertEqual(results.count, 100)
        }
    }
    
    func testConcurrentWrites() async throws {
        let storage = StorageCombine<Int>("test.concurrent.writes", mode: .memory(scope: .singleton), expiration: .none)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    storage.wrappedValue = i
                }
            }
        }
        
        // Wait for all writes to complete
        try await Task.sleep(milliseconds: 200)
        
        // Storage should have some valid value (last write wins)
        let finalValue = storage.wrappedValue
        XCTAssertNotNil(finalValue)
        XCTAssertTrue((0..<100).contains(finalValue!))
    }
    
    func testMultipleInstancesSameKey() async throws {
        let key = "test.multiple.instances"
        let storage1 = StorageCombine<String>(key, mode: .memory(scope: .shared), expiration: .none)
        let storage2 = StorageCombine<String>(key, mode: .memory(scope: .shared), expiration: .none)
        
        storage1.wrappedValue = "from storage1"
        
        // Wait for async write
        try await Task.sleep(milliseconds: 100)
        
        let value2 = storage2.wrappedValue
        XCTAssertEqual(value2, "from storage1")
    }
    
    func testCheckThenSetRaceCondition() async throws {
        let key = "test.check.then.set"
        
        // Create multiple instances rapidly with default values
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    _ = StorageCombine<String>(key, mode: .memory(scope: .shared), defaultValue: "default-\(i)", expiration: .none)
                }
            }
        }
        
        // Wait for initialization
        try await Task.sleep(milliseconds: 200)
        
        // Read the final value - should be one of the defaults, not corrupted
        let finalStorage = StorageCombine<String>(key, mode: .memory(scope: .shared), expiration: .none)
        try await Task.sleep(milliseconds: 50)
        
        let value = finalStorage.wrappedValue
        XCTAssertNotNil(value)
        XCTAssertTrue(value?.starts(with: "default-") == true)
    }
    
    func testConcurrentReadsAndWrites() async throws {
        let storage = StorageCombine<Int>("test.reads.writes", mode: .memory(scope: .shared), expiration: .none)
        storage.wrappedValue = 0
        
        try await Task.sleep(milliseconds: 100)
        
        let completed = await withTaskGroup(of: Bool.self) { group in
            // Add writers
            for i in 0..<50 {
                group.addTask {
                    storage.wrappedValue = i
                    return true
                }
            }
            
            // Add readers
            for _ in 0..<50 {
                group.addTask {
                    _ = storage.wrappedValue
                    return true
                }
            }
            
            var count = 0
            for await success in group {
                if success { count += 1 }
            }
            return count
        }
        
        XCTAssertEqual(completed, 100)
    }
    
    // MARK: - Storage Mode Tests
    
    func testUserDefaultsThreadSafety() async throws {
        let key = "test.userdefaults.threadsafe"
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        
        let storage = StorageCombine<String>(key, mode: .userDefaults(defaults: defaults), expiration: .none)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<20 {
                group.addTask {
                    storage.wrappedValue = "value-\(i)"
                }
            }
        }
        
        try await Task.sleep(milliseconds: 200)
        
        let value = storage.wrappedValue
        XCTAssertNotNil(value)
        
        // Cleanup
        defaults.removeObject(forKey: key)
    }
    
    func testMemorySingletonThreadSafety() async throws {
        let key = "test.singleton.threadsafe"
        let storage1 = StorageCombine<Int>(key, mode: .memory(scope: .singleton), expiration: .none)
        let storage2 = StorageCombine<Int>(key, mode: .memory(scope: .singleton), expiration: .none)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    storage1.wrappedValue = i
                }
                group.addTask {
                    storage2.wrappedValue = i + 100
                }
            }
        }
        
        try await Task.sleep(milliseconds: 200)
        
        let value1 = storage1.wrappedValue
        let value2 = storage2.wrappedValue
        
        // Both should see the same value since they share singleton storage
        XCTAssertEqual(value1, value2)
    }
    
    func testMemoryUniqueIsolation() async throws {
        let key = "test.unique.isolation"
        let storage1 = StorageCombine<String>(key, mode: .memory(scope: .unique), expiration: .none)
        let storage2 = StorageCombine<String>(key, mode: .memory(scope: .unique), expiration: .none)
        
        storage1.wrappedValue = "storage1-value"
        storage2.wrappedValue = "storage2-value"
        
        try await Task.sleep(milliseconds: 100)
        
        XCTAssertEqual(storage1.wrappedValue, "storage1-value")
        XCTAssertEqual(storage2.wrappedValue, "storage2-value")
        XCTAssertNotEqual(storage1.wrappedValue, storage2.wrappedValue)
    }
    
    func testMemorySharedScope() async throws {
        let key = "test.shared.scope"
        let storage1 = StorageCombine<String>(key, mode: .memory(scope: .shared), expiration: .none)
        let storage2 = StorageCombine<String>(key, mode: .memory(scope: .shared), expiration: .none)
        
        storage1.wrappedValue = "shared-value"
        
        try await Task.sleep(milliseconds: 100)
        
        XCTAssertEqual(storage2.wrappedValue, "shared-value")
    }
    
    // MARK: - Combine Publisher Tests
    
    func testPublisherConcurrentUpdates() async throws {
        let storage = StorageCombine<Int>("test.publisher.concurrent", mode: .memory(scope: .shared), expiration: .none)
        
        var receivedValues: [Int?] = []
        let cancellable = storage.projectedValue.sink { value in
            receivedValues.append(value)
        }
        
        // Write multiple values concurrently
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    storage.wrappedValue = i
                }
            }
        }
        
        try await Task.sleep(milliseconds: 300)
        
        // Should have received at least some updates
        XCTAssertTrue(receivedValues.count > 0)
        
        cancellable.cancel()
    }
    
    func testMultipleSubscribers() async throws {
        let storage = StorageCombine<String>("test.multiple.subscribers", mode: .memory(scope: .shared), expiration: .none)
        
        var values1: [String?] = []
        var values2: [String?] = []
        
        let cancellable1 = storage.projectedValue.sink { values1.append($0) }
        let cancellable2 = storage.projectedValue.sink { values2.append($0) }
        
        storage.wrappedValue = "test1"
        try await Task.sleep(milliseconds: 100)
        
        storage.wrappedValue = "test2"
        try await Task.sleep(milliseconds: 100)
        
        XCTAssertTrue(values1.count > 0)
        XCTAssertTrue(values2.count > 0)
        
        cancellable1.cancel()
        cancellable2.cancel()
    }
    
    // MARK: - StorageCombineDefault Tests
    
    func testStorageCombineDefaultThreadSafety() async throws {
        let storage = StorageCombineDefault<Int>("test.default.threadsafe", mode: .memory(scope: .shared), defaultValue: 42)
        
        await withTaskGroup(of: Int.self) { group in
            for _ in 0..<50 {
                group.addTask {
                    return storage.wrappedValue
                }
            }
            
            for await value in group {
                // Should always return a valid value (never crash or corrupt)
                XCTAssertTrue(value >= 0)
            }
        }
    }
    
    func testStorageCombineDefaultConcurrentWrites() async throws {
        let storage = StorageCombineDefault<Int>("test.default.writes", mode: .memory(scope: .shared), defaultValue: 0)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    storage.wrappedValue = i
                }
            }
        }
        
        try await Task.sleep(milliseconds: 200)
        
        let value = storage.wrappedValue
        XCTAssertTrue((0..<100).contains(value))
    }
    
    // MARK: - Expiration Tests
    
    func testExpirationThreadSafety() async throws {
        let storage = StorageCombine<String>(
            "test.expiration.threadsafe",
            mode: .memory(scope: .shared),
            expiration: .seconds(0.1)
        )
        
        storage.wrappedValue = "expires-soon"
        try await Task.sleep(milliseconds: 50)
        
        // Read while not expired
        XCTAssertEqual(storage.wrappedValue, "expires-soon")
        
        // Wait for expiration
        try await Task.sleep(milliseconds: 100)
        
        // Concurrent reads after expiration
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    return storage.wrappedValue
                }
            }
            
            for await value in group {
                // All should be nil (expired)
                XCTAssertNil(value)
            }
        }
    }
    
    // MARK: - Configuration Lock Tests
    
    func testConfigurationInitializationAtomic() async throws {
        let key = "test.config.atomic"
        
        // Create many instances rapidly with same key and default
        let instances = await withTaskGroup(of: StorageCombine<String>.self) { group in
            for _ in 0..<30 {
                group.addTask {
                    return StorageCombine<String>(key, mode: .memory(scope: .shared), defaultValue: "default", expiration: .none)
                }
            }
            
            var results: [StorageCombine<String>] = []
            for await instance in group {
                results.append(instance)
            }
            return results
        }
        
        try await Task.sleep(milliseconds: 200)
        
        // All instances should see consistent value
        let values = instances.map { $0.wrappedValue }
        let uniqueValues = Set(values)
        
        XCTAssertEqual(uniqueValues.count, 1)
        XCTAssertEqual(uniqueValues.first, "default")
    }
    
    // MARK: - Stress Tests
    
    func testHighConcurrencyStress() async throws {
        let storage = StorageCombine<Int>("test.stress.high", mode: .memory(scope: .shared), expiration: .none)
        
        let operations = 1000
        var readCount = 0
        var writeCount = 0
        
        _ = await withTaskGroup(of: String.self) { group in
            for i in 0..<operations {
                if i % 2 == 0 {
                    group.addTask {
                        storage.wrappedValue = i
                        return "write"
                    }
                } else {
                    group.addTask {
                        _ = storage.wrappedValue
                        return "read"
                    }
                }
            }
            
            for await operation in group {
                if operation == "read" {
                    readCount += 1
                } else {
                    writeCount += 1
                }
            }
            
            return (readCount, writeCount)
        }
        
        XCTAssertEqual(readCount + writeCount, operations)
    }
    
    func testRapidInitDealloc() async throws {
        let key = "test.rapid.init"
        
        for i in 0..<100 {
            autoreleasepool {
                let storage = StorageCombine<Int>(key, mode: .memory(scope: .unique), expiration: .none)
                storage.wrappedValue = i
            }
        }
        
        // Should complete without hanging or crashing
        XCTAssertTrue(true)
    }
}

@available(iOS 13.0, macOS 10.15, *)
final class StorageCombineFunctionalTests: XCTestCase {
    
    func testBasicReadWrite() async throws {
        let storage = StorageCombine<String>("test.basic", mode: .memory(scope: .shared), expiration: .none)
        
        storage.wrappedValue = "test value"
        try await Task.sleep(milliseconds: 50)
        
        XCTAssertEqual(storage.wrappedValue, "test value")
    }
    
    func testDefaultValue() async throws {
        let storage = StorageCombine<Int>("test.default.value", mode: .memory(scope: .unique), defaultValue: 99, expiration: .none)
        
        try await Task.sleep(milliseconds: 50)
        
        XCTAssertEqual(storage.wrappedValue, 99)
    }
    
    func testClearValue() async throws {
        let storage = StorageCombine<String>("test.clear", mode: .memory(scope: .shared), expiration: .none)
        
        storage.wrappedValue = "temporary"
        try await Task.sleep(milliseconds: 50)
        
        storage.wrappedValue = nil
        try await Task.sleep(milliseconds: 50)
        
        XCTAssertNil(storage.wrappedValue)
    }
    
    func testCodableComplexTypes() async throws {
        struct User: Codable, Equatable {
            let id: Int
            let name: String
        }
        
        let storage = StorageCombine<User>("test.codable", mode: .memory(scope: .shared), expiration: .none)
        let user = User(id: 1, name: "John Doe")
        
        storage.wrappedValue = user
        try await Task.sleep(milliseconds: 50)
        
        XCTAssertEqual(storage.wrappedValue, user)
    }
    
    func testExpirationSeconds() async throws {
        let storage = StorageCombine<String>(
            "test.expiration.seconds",
            mode: .memory(scope: .shared),
            expiration: .seconds(0.1)
        )
        
        storage.wrappedValue = "expires"
        try await Task.sleep(milliseconds: 50)
        XCTAssertEqual(storage.wrappedValue, "expires")
        
        // Wait for expiration plus a bit more for async clear to complete
        try await Task.sleep(milliseconds: 150)
        XCTAssertNil(storage.wrappedValue)
    }
    
    func testPublisherInitialValue() async throws {
        let storage = StorageCombine<String>("test.publisher.initial", mode: .memory(scope: .shared), defaultValue: "initial", expiration: .none)
        
        var receivedValue: String?
        let cancellable = storage.projectedValue.sink { value in
            receivedValue = value
        }
        
        try await Task.sleep(milliseconds: 100)
        
        XCTAssertEqual(receivedValue, "initial")
        cancellable.cancel()
    }
    
    func testStorageCombineDefaultNeverNil() async throws {
        let storage = StorageCombineDefault<Int>("test.never.nil", mode: .memory(scope: .shared), defaultValue: 100)
        
        // Even without setting a value, should return default
        XCTAssertEqual(storage.wrappedValue, 100)
        
        // After setting
        storage.wrappedValue = 200
        try await Task.sleep(milliseconds: 50)
        XCTAssertEqual(storage.wrappedValue, 200)
    }
}
