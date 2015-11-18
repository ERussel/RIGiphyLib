//
//  GiphyImageCacheProtocol.h
//  GiphyTest
//
//  Created by Russel on 20.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol designed to extend NSObject protocol to provide methods to interact with cache.
 */
@protocol GiphyObjectCacheProtocol <NSObject>

/**
 *  Adds object to cache.
 *  @param object           Object conforming NSCoding protocol to save in cache.
 *  @param key              Unique identifier to associate object with.
 *  @param callbackQueue    Queue to call completion block in.
 *  @param completion       Block to call when operation completes
 */
- (void)addObjectToCache:(id<NSCoding>)object
                 forKey:(NSString*)key
          callbackQueue:(dispatch_queue_t)callbackQueue
             completion:(void (^)(void))completion;

/**
 *  Try to extract object from cache.
 *  @param key              NSString key associated with cached object.
 *  @param callbackQueue    Queue to call completion block in.
 *  @param completion       Block to call when operation completes
 */
- (void)fetchCachedObjectForKey:(NSString*)key
                  callbackQueue:(dispatch_queue_t)callbackQueue
                     completion:(void (^)(id<NSCoding> object))completion;

@end
