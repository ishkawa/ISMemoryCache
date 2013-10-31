#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "ISMemoryCache.h"

static NSString *ISTestKey = @"test";

@interface ISMemoryCacheTests : SenTestCase {
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
    STAssertEquals([cache objectForKey:ISTestKey], object, @"object for key should equal inserted object.");
    STAssertTrue([[cache allKeys] containsObject:ISTestKey], nil);
}

- (void)testRemoveObjectForKey
{
    NSObject *object = [[NSObject alloc] init];
    [cache setObject:object forKey:ISTestKey];
    [cache removeObjectForKey:ISTestKey];
    STAssertNil([cache objectForKey:ISTestKey], @"cache should not contain object for key.");
    STAssertFalse([[cache allKeys] containsObject:ISTestKey], nil);
}

- (void)testRemoveUnretainedObjects
{
    @autoreleasepool {
        NSObject *unretainedObject = [[NSObject alloc] init];
        [cache setObject:unretainedObject forKey:ISTestKey];
    }
    [cache removeUnretainedObjects];
    STAssertNil([cache objectForKey:ISTestKey], @"object for key should be removed.");
}

- (void)testNotRemoveRetainedObjects
{
    NSObject *retainedObject = [[NSObject alloc] init];
    @autoreleasepool {
        [cache setObject:retainedObject forKey:ISTestKey];
    }
    [cache removeUnretainedObjects];
    STAssertEquals([cache objectForKey:ISTestKey], retainedObject, @"object for key should not be removed.");
}

- (void)testHandleMemoryWarning
{
    id mock = [OCMockObject partialMockForObject:cache];
    [[mock expect] removeUnretainedObjects];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *name = UIApplicationDidReceiveMemoryWarningNotification;
    [center postNotificationName:name object:nil];
}

@end
