import UIKit
import XCTest
import ISMemoryCache

class ISMemoryCacheTests: XCTestCase {
    var cache: ISMemoryCache!
    
    override func setUp() {
        super.setUp()
        cache = ISMemoryCache()
    }
    
    override func tearDown() {
        cache = nil
        super.tearDown()
    }
    
    func testSetAndGetValue() {
        let key = "key"
        let value = NSObject()
        
        cache[key] = value
        
        if let cachedValue = cache[key] as? NSObject {
            XCTAssertEqual(cachedValue, value)
        } else {
            XCTFail()
        }
    }
    
    func testRemoveValue() {
        let key = "key"
        let value = NSObject()
        
        cache[key] = value
        cache[key] = nil
        
        XCTAssertNil(cache[key])
    }
    
    func testRemoveUnretainedValues() {
        let key = "key"
        
        autoreleasepool {
            self.cache[key] = NSObject()
        }
        
        cache.performClearAction(.RemoveUnretainedObjects)
        
        XCTAssertNil(cache[key])
    }
    
    func testAvoidRemovingRetainedValues() {
        let key = "key"
        let value = NSObject()
        
        autoreleasepool {
            self.cache[key] = value
        }
        
        cache.performClearAction(.RemoveUnretainedObjects)
        
        if let cachedValue = cache[key] as? NSObject {
            XCTAssertEqual(cachedValue, value)
        } else {
            XCTFail()
        }
    }
    
    func testHandleApplicationDidEnterBackgroundNotification() {
        let key = "key"
        
        autoreleasepool {
            self.cache[key] = NSObject()
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(UIApplicationDidEnterBackgroundNotification, object: nil)
        
        XCTAssertNil(cache[key])
    }
    
    func testHandleApplicationDidReceiveMemoryWarningNotification() {
        let key = "key"
        
        autoreleasepool {
            self.cache[key] = NSObject()
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        
        XCTAssertNil(cache[key])
    }
    
    func testThreadSafety() {
        let queue = NSOperationQueue()
        
        for var i = 0; i < 10000; i++ {
            let key = "\(i)"
            let value = NSObject()
            
            queue.addOperationWithBlock {
                self.cache[key] = value
            }
            
            queue.addOperationWithBlock {
                self.cache[key] = self.cache[key]
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
}
