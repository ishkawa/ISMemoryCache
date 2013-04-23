#import "Kiwi.h"
#import "ISMemoryCache.h"

SPEC_BEGIN(ISMemoryCacheSpec)

static NSString *ISTestKey = @"test";

describe(@"ISMemoryCache", ^{
    __block ISMemoryCache *cache;
    
    beforeEach(^{
        cache = [[ISMemoryCache alloc] init];
    });
    
    it(@"calls removeUnretainedObjects on receiving UIApplicationDidReceiveMemoryWarningNotification", ^{
        [[cache should] receive:@selector(removeUnretainedObjects)];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSString *name = UIApplicationDidReceiveMemoryWarningNotification;
        [center postNotificationName:name object:nil];
    });
    
    context(@"it had an unretained object and called removeUnretainedObjects", ^{
        beforeEach(^{
            @autoreleasepool {
                NSObject *unretainedObject = [[NSObject alloc] init];
                [cache setObject:unretainedObject forKey:ISTestKey];
            }
            [cache removeUnretainedObjects];
        });
        
        it(@"does not have the unretained object", ^{
            [[cache objectForKey:ISTestKey] shouldBeNil];
        });
    });
    
    context(@"it had a retained object and called removeUnretainedObjects", ^{
        __block NSObject *retainedObject;
        
        beforeEach(^{
            retainedObject = [[NSObject alloc] init];
            
            @autoreleasepool {
                [cache setObject:retainedObject forKey:ISTestKey];
            }
            [cache removeUnretainedObjects];
        });
        
        it(@"has the retained object", ^{
            [[[cache objectForKey:ISTestKey] should] equal:retainedObject];
        });
    });
    
    context(@"has an object", ^{
        __block NSObject *object;
        
        beforeEach(^{
            object = [[NSObject alloc] init];
            [cache setObject:object forKey:ISTestKey];
        });
        
        it(@"returns same object", ^{
            [[[cache objectForKey:ISTestKey] should] equal:object];
        });
        
        it(@"returns nil after removed object for the key", ^{
            [cache removeObjectForKey:ISTestKey];
            [[cache objectForKey:ISTestKey] shouldBeNil];
        });
        
        it(@"contains ISTestKey in allKeys", ^{
            [[[cache allKeys] should] contain:ISTestKey];
        });
    });
});

SPEC_END


