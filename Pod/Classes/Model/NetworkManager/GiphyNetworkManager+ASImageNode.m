//
//  GiphyNetworkManager+ASImageNode.m
//  GiphyTest
//
//  Created by Russel on 20.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyNetworkManager+ASImageNode.h"

@implementation GiphyNetworkManager (ASImageNode)

#pragma mark - ASImageDownloaderProtocol

- (id)downloadImageWithURL:(NSURL *)URL
             callbackQueue:(dispatch_queue_t)callbackQueue
     downloadProgressBlock:(void (^)(CGFloat progress))downloadProgressBlock
                completion:(void (^)(CGImageRef image, NSError *error))completion{
    
    return [self getStillByURL:URL
                   cachePolicy:kGiphyRequestCachePolicyReturnCachedElseLoad
                  successBlock:^(UIImage *stillImage){
                      if (completion) {
                          if (callbackQueue) {
                              dispatch_async(callbackQueue, ^{
                                  completion(stillImage.CGImage, nil);
                              });
                          }else{
                              completion(stillImage.CGImage, nil);
                          }
                      }
                  } progressBlock:downloadProgressBlock
                  failureBlock:^(NSError *error){
                      if (completion) {
                          if (callbackQueue) {
                              dispatch_async(callbackQueue, ^{
                                  completion(nil, error);
                              });
                          }else{
                              completion(nil, error);
                          }
                      }
                  }];
}

- (void)cancelImageDownloadForIdentifier:(id)downloadIdentifier{
    [self cancelRequestForCancellationIdentifier:downloadIdentifier];
}


@end
