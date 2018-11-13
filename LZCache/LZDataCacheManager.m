//
//  LZDataCacheManager.m
//  LZCache
//
//  Created by lizheng on 2018/11/13.
//  Copyright © 2018年 lizheng. All rights reserved.
//

#import "LZDataCacheManager.h"
#import "LZCacheDao.h"

@interface LZDataCacheManager ()
{
    LZCacheDao *_cacheDao;
}
@end

@implementation LZDataCacheManager

+ (instancetype)sharedManager {
    static  LZDataCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init{
    self = [super init];
    if(self){
        [self setup];
        [self restore];
        [self registerMemoryWarningNotification];
    }
    return self;
}

- (void)registerMemoryWarningNotification{
#if TARGET_OS_IPHONE
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemoryCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
#ifdef __IPHONE_4_0
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported){
        // When in background, clean memory in order to have less chance to be killed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemoryCache)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
#endif
#endif
}

- (void)setup{
    _dataCacheType = LZDataCacheFile;
    [self setupDao];
}

- (void)setupDao{
    switch (_dataCacheType) {
        case LZDataCacheFile:
            _cacheDao = [[NSClassFromString(@"LZFileCacheDao") alloc] init];
            break;
        case LZDataCacheUserDefault:
            _cacheDao = [[NSClassFromString(@"LZUserDefaultCacheDao") alloc] init];
            break;
        default:
            _cacheDao = [[NSClassFromString(@"LZFileCacheDao") alloc] init];
            break;
    }
}

- (void)restore{
    [_cacheDao restore];
}

- (BOOL)hasObjectInCacheByKey:(NSString*)key{
    return [_cacheDao hasObjectInCacheByKey:key];
}

- (NSObject*)getCachedObjectByKey:(NSString*)key{
    return [_cacheDao getCachedObjectByKey:key];
}

- (void)clearAllCache{
    [_cacheDao clearAllCache];
}

- (void)clearAllDiskCache{
    [_cacheDao clearAllDiskCache];
}

- (void)clearMemoryCache{
    [_cacheDao clearMemoryCache];
}

- (void)addObject:(NSObject*)obj forKey:(NSString*)key{
    [_cacheDao addObject:obj forKey:key];
}

- (void)addObjectToMemory:(NSObject*)obj forKey:(NSString*)key{
    [_cacheDao addObjectToMemory:obj forKey:key];
}

- (void)removeObjectInCacheByKey:(NSString*)key{
    [_cacheDao removeObjectInCacheByKey:key];
}

- (void)doSave{
    [_cacheDao doSave];
}

- (void)setDataCacheType:(LZDataCacheType)dataCacheType{
    if (_dataCacheType != dataCacheType) {
        _dataCacheType = dataCacheType;
        [self setupDao];
    }
}


@end
