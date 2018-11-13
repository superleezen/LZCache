//
//  LZCacheDao.m
//  LZCache
//
//  Created by lizheng on 2018/11/13.
//  Copyright © 2018年 lizheng. All rights reserved.
//

#import "LZCacheDao.h"

#define LZSHOULDOVERRIDE(basename, subclassname){ NSAssert([basename isEqualToString:subclassname], @"subclass should override the method!");}

@implementation LZCacheDao

- (BOOL)hasObjectInCacheByKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
    return TRUE;
}

- (BOOL)hasObjectInMemoryByKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
    return TRUE;
}

- (id)getCachedObjectByKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
    return nil;
}

- (void)restore{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

- (void)clearAllCache{
    
}

- (void)clearAllDiskCache{
    
}

- (void)clearMemoryCache{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

- (void)addObject:(NSObject*)obj forKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

- (void)addObjectToMemory:(NSObject*)obj forKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

- (void)removeObjectInCacheByKey:(NSString*)key{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

- (void)doSave{
    LZSHOULDOVERRIDE(@"LZCacheDao", NSStringFromClass([self class]));
}

@end
