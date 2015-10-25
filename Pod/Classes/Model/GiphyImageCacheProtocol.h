//
//  GiphyImageCacheProtocol.h
//  GiphyTest
//
//  Created by Russel on 20.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASImageProtocols.h>

@protocol GiphyImageCacheProtocol <ASImageCacheProtocol>

- (void)addImageToCache:(UIImage*)image
                 forURL:(NSURL *)URL
          callbackQueue:(dispatch_queue_t)callbackQueue
             completion:(void (^)(void))completion;

@end
