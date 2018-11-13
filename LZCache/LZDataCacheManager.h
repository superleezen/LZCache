//
//  LZDataCacheManager.h
//  LZCache
//  轻量级缓存管理器，利用UserDefault进行缓存管理，大数据量是效率有问题
//  两种数据缓存的方式 LZUserDefaultCacheDao 和 LZFileCacheDao 方式
//  修改setup方法可改变Dao
//
//  Created by lizheng on 2018/11/13.
//  Copyright © 2018年 lizheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DataCacheManagerCacheType){
    DataCacheManagerCacheTypeMemory = 0,
    DataCacheManagerCacheTypePersist,
};

typedef NS_ENUM(NSUInteger, LZDataCacheType){
    LZDataCacheNone = 0,
    LZDataCacheUserDefault,
    LZDataCacheFile,
};

NS_ASSUME_NONNULL_BEGIN

@interface LZDataCacheManager : NSObject

@property (nonatomic, assign) LZDataCacheType dataCacheType;
+ (LZDataCacheManager *)sharedManager;
/*!
 * @param key the key
 * @returns Returns a Boolean value that indicates whether a given object is present in the local disk and memory cache pool
 */
- (BOOL)hasObjectInCacheByKey:(NSString*)key;
/*!
 * Returns a Boolean value that indicates whether a given object is present in the local disk and memory cache pool
 * @param key the key
 */
- (id)getCachedObjectByKey:(NSString*)key;
/*!
 * restore all cached objects
 */
- (void)restore;
/*!
 * clear all cached objects in disk and memory
 */
- (void)clearAllCache;
/*!
 * clear all cached objects in disk
 */
- (void)clearAllDiskCache;
/*!
 * clear all memory cached objects
 */
- (void)clearMemoryCache;
/*!
 *    cache object in memory and disk, all cache object will when user exit the app
 *    @param    obj    The object to add to the memory cache pool. This value must not be nil
 *    @param    key The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol).
 *          If aKey already exists in the dictionary anObject takes its place.
 */
- (void)addObject:(NSObject*)obj forKey:(NSString*)key;
/*!
 *    cache object in memory, all cache object will when user exit the app
 *    @param    obj    The object to add to the memory cache pool. This value must not be nil
 *    @param    key The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol).
 *          If aKey already exists in the dictionary anObject takes its place.
 */
- (void)addObjectToMemory:(NSObject*)obj forKey:(NSString*)key;
/*!
 *    remove cached object with specified key
 *    @param    key    The key to remove from the memory cache pool. This value must not be nil, otherwise nothing will happen
 */
- (void)removeObjectInCacheByKey:(NSString*)key;
/*!
 *    save all cached objects to disk
 */
- (void)doSave;

@end

NS_ASSUME_NONNULL_END
