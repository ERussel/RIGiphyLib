//
//  TMCache+GiphyCacheProtocol.m
//  RIGiphyLib
//
//  Created by Russel on 18.11.15.
//  Copyright © 2015 Russel. All rights reserved.
//

#import "TMCache+GiphyCacheProtocol.h"

@implementation TMCache (GiphyCacheProtocol)

#pragma mark - Giphy Cache Protocol

- (void)fetchCachedObjectForKey:(NSString *)key
                  callbackQueue:(dispatch_queue_t)callbackQueue
                     completion:(void (^)(id<NSCoding>))completion{
    [self objectForKey:key block:^(TMCache *cache, NSString *key, id object){
        if (completion) {
            dispatch_queue_t queue = callbackQueue != NULL ? callbackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                completion(object);
            });
        }
    }];
}

- (void)addObjectToCache:(id<NSCoding>)object
                  forKey:(NSString *)key
           callbackQueue:(dispatch_queue_t)callbackQueue
              completion:(void (^)(void))completion{
    [self setObject:object forKey:key block:^(TMCache *cache, NSString *key, id object){
        if (completion) {
            dispatch_queue_t queue = callbackQueue != NULL ? callbackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                completion();
            });
        }
    }];
}

@end
