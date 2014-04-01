#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ISMemoryCache.h"

static NSString *ISTestKey = @"test";

@interface ISMemoryCacheTests : XCTestCase {
    ISMemoryCache *cache;
}

@end

@implementation ISMemoryCacheTests

- (void)setUp
{
    [super setUp];
    cache = [[ISMemoryCache alloc] init];
}

- (void)tearDown
{
    cache = nil;
    [super tearDown];
}

- (void)testSharedCache
{
    ISMemoryCache *cache1 = [ISMemoryCache sharedCache];
    ISMemoryCache *cache2 = [ISMemoryCache sharedCache];
    XCTAssertEqual(cache1, cache2, @"shared instance should returns same instance.");
}

- (void)testDefaultClearingTypes
{
    XCTAssertEqual(cache.clearingTypeOnMemoryWarning, ISMemoryCacheClearingTypeAllObjects);
    XCTAssertEqual(cache.clearingTypeOnEnteringBackground, ISMemoryCacheClearingTypeUnretainedObjects);
}

- (void)testInitWithObjectsForKeys
{
    NSDictionary *dictionary = @{@"foo": @"hoge", @"bar": @123, @"baz": [NSDate date]};
    ISMemoryCache *initializedCache = [[ISMemoryCache alloc] initWithObjects:[dictionary allValues]
                                                          forKeys:[dictionary allKeys]];
    
    XCTAssertEqualObjects([initializedCache performSelector:@selector(dictionary)], dictionary);
}

- (void)testSetObjectForKey
{
    NSObject *object = [[NSObject alloc] init];
    [cache setObject:object forKey:ISTestKey];
    XCTAssertEqual([cache objectForKey:ISTestKey], object, @"object for key should equal inserted object.");
    XCTAssertTrue([[cache allKeys] containsObject:ISTestKey]);
}

- (void)testRemoveObjectForKey
{
    NSObject *object = [[NSObject alloc] init];
    [cache setObject:object forKey:ISTestKey];
    [cache removeObjectForKey:ISTestKey];
    XCTAssertNil([cache objectForKey:ISTestKey], @"cache should not contain object for key.");
    XCTAssertFalse([[cache allKeys] containsObject:ISTestKey]);
}

- (void)testRemoveUnretainedObjects
{
    @autoreleasepool {
        NSObject *unretainedObject = [[NSObject alloc] init];
        [cache setObject:unretainedObject forKey:ISTestKey];
    }
    [cache removeUnretainedObjects];
    XCTAssertNil([cache objectForKey:ISTestKey], @"object for key should be removed.");
}

- (void)testNotRemoveRetainedObjects
{
    NSObject *retainedObject = [[NSObject alloc] init];
    @autoreleasepool {
        [cache setObject:retainedObject forKey:ISTestKey];
    }
    [cache removeUnretainedObjects];
    XCTAssertEqual([cache objectForKey:ISTestKey], retainedObject, @"object for key should not be removed.");
}

- (void)testHandlingMemoryWarning
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *name = UIApplicationDidReceiveMemoryWarningNotification;
    id mock;
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnMemoryWarning = ISMemoryCacheClearingTypeNone;
    [[mock reject] removeAllObjects];
    [[mock reject] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnMemoryWarning = ISMemoryCacheClearingTypeUnretainedObjects;
    [[mock reject] removeAllObjects];
    [[mock expect] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnMemoryWarning = ISMemoryCacheClearingTypeAllObjects;
    [[mock expect] removeAllObjects];
    [[mock reject] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
}

- (void)testHandlingEnteringBackground
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *name = UIApplicationDidEnterBackgroundNotification;
    id mock;
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnEnteringBackground = ISMemoryCacheClearingTypeNone;
    [[mock reject] removeAllObjects];
    [[mock reject] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnEnteringBackground = ISMemoryCacheClearingTypeUnretainedObjects;
    [[mock reject] removeAllObjects];
    [[mock expect] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
    
    mock = [OCMockObject partialMockForObject:cache];
    cache.clearingTypeOnEnteringBackground = ISMemoryCacheClearingTypeAllObjects;
    [[mock expect] removeAllObjects];
    [[mock reject] removeUnretainedObjects];
    [center postNotificationName:name object:nil];
    XCTAssertNoThrow([mock verify]);
}

- (void)testReadAndWriteFromMultipleThreads
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (NSInteger index = 0; index < 1000000; index++) {
        [queue addOperationWithBlock:^{
            [cache setObject:@(index) forKey:ISTestKey];
            [cache objectForKey:ISTestKey];
        }];
    }
    [queue waitUntilAllOperationsAreFinished];
}

@end
