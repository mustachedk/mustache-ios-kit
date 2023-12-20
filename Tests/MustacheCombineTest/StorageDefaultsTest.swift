
import XCTest
import MustacheCombine

@available(iOS 13.0, *)
final class StorageDefaultsTest: XCTestCase {
    
    @StorageCombine("defaultsSeconds", mode: .userDefaults(), expiration: .seconds(2))
    var defaultsSeconds: StoredObject?

    @StorageCombine("defaultsTimeStampNow", mode: .userDefaults(), expiration: .timestamp(Date.nowSafe))
    var defaultsTimeStampNow: StoredObject?
    
    @StorageCombine("defaultsTimeStampFuture", mode: .userDefaults(), expiration: .timestamp(Date.distantFuture))
    var defaultsTimeStampFuture: StoredObject?
    
    @StorageCombine("defaultsHour", mode: .userDefaults(), expiration: .hourOfDay(2))
    var defaultsHour: StoredObject?
    
    @StorageCombine("defaultsDay", mode: .userDefaults(), expiration: .dayOfWeek(2))
    var defaultsDay: StoredObject?
    
    @StorageCombine("defaultsNone", mode: .userDefaults(), expiration: .none)
    var defaultsNone: StoredObject?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.defaultsSeconds = nil
        self.defaultsTimeStampNow = nil
        self.defaultsTimeStampFuture = nil
        self.defaultsHour = nil
        self.defaultsDay = nil
        self.defaultsNone = nil
        
    }
    
    func testDefaultsSeconds() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsSeconds)
        self.defaultsSeconds = stored
        XCTAssertEqual(self.defaultsSeconds, stored)
        
        sleep(6)
        
        XCTAssertNil(self.defaultsSeconds)
                
    }
    
    func testDefaultsTimeStampNow() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsTimeStampNow)
        self.defaultsTimeStampNow = stored
        XCTAssertNil(self.defaultsTimeStampNow)
        
    }
    
    func testDefaultsTimeStampFuture() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsTimeStampFuture)
        self.defaultsTimeStampFuture = stored
        XCTAssertEqual(self.defaultsTimeStampFuture, stored)
        
    }
    
    func testDefaultsHour() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsHour)
        self.defaultsHour = stored
        XCTAssertEqual(self.defaultsHour, stored)

    }
    
    func testDefaultsDay() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsDay)
        self.defaultsDay = stored
        XCTAssertEqual(self.defaultsDay, stored)
        
    }
    
    func testDefaulsNone() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsNone)
        self.defaultsNone = stored
        XCTAssertEqual(self.defaultsNone, stored)
        self.defaultsNone = nil
        XCTAssertNil(self.defaultsNone)
    }

}
