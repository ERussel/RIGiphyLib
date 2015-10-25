//
//  GiphyNavigationController.h
//  Pods
//
//  Created by Russel on 25.10.15.
//
//

#import <UIKit/UIKit.h>
#import "GiphyImageCacheProtocol.h"
#import "GiphyDataStoreProtocol.h"
#import "GiphyNetworkActivityProtocol.h"

@interface GiphyNavigationController : UINavigationController

- (instancetype)initWithImageCache:(id<GiphyImageCacheProtocol>)imageCache
                         dataManager:(id<GiphyDataStoreProtocol>)dataManager
                    networkActivityManager:(id<GiphyNetworkActivityProtocol>)networkActivityManager;

@end
