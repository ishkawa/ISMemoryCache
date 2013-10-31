#import "ISMemoryCache.h"

@interface ISMemoryCache ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
#else
@property (nonatomic, assign) dispatch_semaphore_t semaphore;
#endif

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
        _semaphore = dispatch_semaphore_create(1);
        _dictionary = [NSMutableDictionary dictionary];
        
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
#if !OS_OBJECT_USE_OBJC
    dispatch_release(self.semaphore);
#endif
}

#pragma mark -

- (void)removeUnretainedObjects
{
    for (NSString *key in [self allKeys]) {
        __weak id wobject;
        
        @autoreleasepool {
            wobject = [self objectForKey:key];
            [self removeObjectForKey:key];
        }
        
        if (wobject) {
            [self setObject:wobject forKey:key];
        }
    }
}

#pragma mark - NSDictionary

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    self = [self init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    return self;
}

- (NSUInteger)count
{
    return [self.dictionary count];
}

- (id)objectForKey:(id)key
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    id object = [self.dictionary objectForKey:key];
    dispatch_semaphore_signal(self.semaphore);
    return object;
}

- (NSEnumerator *)keyEnumerator
{
    return [self.dictionary keyEnumerator];
}

#pragma mark - NSMutableDictionary

- (void)setObject:(id)object forKey:(id <NSCopying>)key
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.dictionary setObject:object forKey:key];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)removeObjectForKey:(id)key
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.dictionary removeObjectForKey:key];
    dispatch_semaphore_signal(self.semaphore);
}

@end
