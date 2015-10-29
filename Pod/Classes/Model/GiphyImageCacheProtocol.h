//
//  GiphyImageCacheProtocol.h
//  GiphyTest
//
//  Created by Russel on 20.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASImageProtocols.h>

/**
 *  Protocol designed to extend ASImageCacheProtocol to provide additional methods.
 */
@protocol GiphyImageCacheProtocol <ASImageCacheProtocol>

/**
 *  Adds image to cache.
 *  @param image            UIImage to save in cache.
 *  @param URL              URL to save image with.
 *  @param callbackQueue    Queue to call completion block in.
 *  @param completion       Block to call when operation completes
 */
- (void)addImageToCache:(UIImage*)image
                 forURL:(NSURL *)URL
          callbackQueue:(dispatch_queue_t)callbackQueue
             completion:(void (^)(void))completion;

@end
