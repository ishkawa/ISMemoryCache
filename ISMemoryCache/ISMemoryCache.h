#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ISMemoryCacheClearingType) {
    ISMemoryCacheClearingTypeNone,
    ISMemoryCacheClearingTypeUnretainedObjects,
    ISMemoryCacheClearingTypeAllObjects,
};

@interface ISMemoryCache : NSMutableDictionary

@property (nonatomic) ISMemoryCacheClearingType clearingTypeOnMemoryWarning;
@property (nonatomic) ISMemoryCacheClearingType clearingTypeOnEnteringBackground;

+ (ISMemoryCache *)sharedCache;
- (void)removeUnretainedObjects;

@end
