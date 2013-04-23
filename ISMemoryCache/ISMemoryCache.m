#import "ISMemoryCache.h"

@interface ISMemoryCache ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation ISMemoryCache

+ (ISMemoryCache *)sharedCache
{
    static ISMemoryCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[ISMemoryCache alloc] init];
    });
    
    return cache;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(removeUnretainedObjects)
                       name:UIApplicationDidReceiveMemoryWarningNotification
                     object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)removeUnretainedObjects
{
    for (NSString *key in [self.dictionary allKeys]) {
        __weak id wobject;
        
        @autoreleasepool {
            wobject = [self.dictionary objectForKey:key];
            [self.dictionary removeObjectForKey:key];
        }
        
        if (wobject) {
            [self.dictionary setObject:wobject forKey:key];
        }
    }
}

#pragma mark - NSDictionary

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    self = [self init];
    if (self) {
        self.dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    return self;
}

- (NSUInteger)count
{
    return [self.dictionary count];
}

- (id)objectForKey:(id)key
{
    return [self.dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.dictionary keyEnumerator];
}

#pragma mark - NSMutableDictionary

- (void)setObject:(id)object forKey:(id <NSCopying>)key
{
    [self.dictionary setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.dictionary removeObjectForKey:key];
}

@end
