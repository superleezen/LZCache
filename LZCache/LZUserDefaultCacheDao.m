//
//  LZUserDefaultCacheDao.m
//  LZCache
//
//  Created by lizheng on 2018/11/13.
//  Copyright © 2018年 lizheng. All rights reserved.
//

#import "LZUserDefaultCacheDao.h"

@interface LZUserDefaultCacheDao ()
{
    NSMutableArray      *_memoryCacheKeys;      // keys for objects only cached in memory
    NSMutableArray      *_keys;                 // keys for keys not managed by queue
    NSMutableDictionary *_memoryCachedObjects;  // objects only cached in memory
    NSOperationQueue    *_cacheInQueue;         // manager cache operation
}
@end

@implementation LZUserDefaultCacheDao

- (BOOL)isValidKey:(NSString*)key{
    if (!key || [key length] == 0 || (NSNull*)key == [NSNull null]) {
        return NO;
    }
    return YES;
}

- (id)archivedObjectWithObject:(id)object{
    return [NSKeyedArchiver archivedDataWithRootObject:object];
}

- (id)unarchivedObjectWithKey:(NSString*)key{
    id objectData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:objectData];
}

- (void)storeToDisk:(NSDictionary *)dic{
    @autoreleasepool {
        NSString *key = [dic objectForKey:@"key"];
        NSObject *data = [dic objectForKey:@"data"];
        [[NSUserDefaults standardUserDefaults] setObject:[self archivedObjectWithObject:_keys] forKey:UD_KEY_DATA_CACHE_KEYS];
        [[NSUserDefaults standardUserDefaults] setObject:[self archivedObjectWithObject:data] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)addObjectWithKey:(NSObject *)object key:(NSString *)key{
    NSDictionary *saveDataDic = [NSDictionary dictionaryWithObjectsAndKeys:key, @"key", object, @"data", nil];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(storeToDisk:) object:saveDataDic];
    [_cacheInQueue addOperation:operation];
}

#pragma mark - lifecycle
- (id)init{
    self = [super init];
    if (self) {
        [self restore];
    }
    return self;
}

#pragma mark - public methods

- (void)restore{
    //init operation queue
    _cacheInQueue = [[NSOperationQueue alloc] init];
    [_cacheInQueue setMaxConcurrentOperationCount:1];
    
    //restore all cached keys, otherwise create an empty nsmutablearray
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UD_KEY_DATA_CACHE_KEYS]) {
        NSArray *keysArray = [self unarchivedObjectWithKey:UD_KEY_DATA_CACHE_KEYS];
        _keys = [[NSMutableArray alloc] initWithArray:keysArray];
    }
    else{
        _keys = [[NSMutableArray alloc] init];
    }
    //restore all memory cached keys and objects
    _memoryCacheKeys = [[NSMutableArray alloc] init];
    _memoryCachedObjects = [[NSMutableDictionary alloc] init];
}

- (void)clearAllCache{
    [self clearMemoryCache];
    [self clearAllDiskCache];
}

- (void)clearMemoryCache{
    [_memoryCacheKeys removeAllObjects];
    [_memoryCachedObjects removeAllObjects];
}

- (void)clearAllDiskCache{
    NSArray *allKeys = [NSArray arrayWithArray:_keys];
    [_keys removeAllObjects];
    [self doSave];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *key in allKeys) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)addObject:(NSObject*)obj forKey:(NSString*)key{
    if (![self isValidKey:key]) {
        return;
    }
    if (!obj || (NSNull*)obj == [NSNull null]) {
        return;
    }
    if (![_keys containsObject:key]) {
        [_keys addObject:key];
    }
    if (![_memoryCacheKeys containsObject:key]) {
        [_memoryCacheKeys addObject:key];
    }
    [_memoryCachedObjects setObject:obj forKey:key];
    [self addObjectWithKey:obj key:key];
}

- (void)addObjectToMemory:(NSObject*)obj forKey:(NSString*)key{
    if (![self isValidKey:key]) {
        return;
    }
    if (!obj || (NSNull*)obj == [NSNull null]) {
        return;
    }
    if ([_memoryCacheKeys containsObject:key]) {
        [_memoryCacheKeys removeObject:key];
        [_memoryCachedObjects removeObjectForKey:key];
    }
    [_memoryCacheKeys addObject:key];
    _memoryCachedObjects[key] = obj;
}

- (id)getCachedObjectByKey:(NSString*)key{
    if (![self isValidKey:key]) {
        return nil;
    }
    
    if ([self hasObjectInMemoryByKey:key]) {
        return _memoryCachedObjects[key];
    }else {
        NSObject *obj = (NSObject *)[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
        if (obj) {
            [_memoryCachedObjects setObject:obj forKey:key];
        }
        return obj;
    }
}

- (BOOL)hasObjectInMemoryByKey:(NSString*)key{
    if ([_memoryCacheKeys containsObject:key]) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL)hasObjectInCacheByKey:(NSString*)key{
    if ([self hasObjectInMemoryByKey:key]) {
        return TRUE;
    }
    if ([_keys containsObject:key]) {
        return TRUE;
    }
    return FALSE;
}

- (void)removeObjectInCacheByKey:(NSString*)key{
    if (![self isValidKey:key]) {
        return;
    }
    [_keys removeObject:key];
    [_memoryCachedObjects removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [self doSave];
}

- (void)doSave
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_keys] forKey:UD_KEY_DATA_CACHE_KEYS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
