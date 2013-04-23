#import <Foundation/Foundation.h>

@interface ISMemoryCache : NSMutableDictionary

+ (ISMemoryCache *)sharedCache;

- (void)removeUnretainedObjects;

@end
