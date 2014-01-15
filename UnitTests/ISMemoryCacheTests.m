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

- (void)testHandleMemoryWarning
{
    id mock = [OCMockObject partialMockForObject:cache];
    [[mock expect] removeUnretainedObjects];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *name = UIApplicationDidReceiveMemoryWarningNotification;
    [center postNotificationName:name object:nil];
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