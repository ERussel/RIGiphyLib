//
//  GiphyNavigationController.m
//  Pods
//
//  Created by Russel on 25.10.15.
//
//

#import "GiphyNavigationController.h"
#import "GiphyListViewController.h"
#import "GiphyNetworkManager.h"
#import "GiphyBasicDataManager.h"

@implementation GiphyNavigationController

- (instancetype)initWithImageCache:(id<GiphyImageCacheProtocol>)imageCache
                       dataManager:(id<GiphyDataStoreProtocol>)dataManager
            networkActivityManager:(id<GiphyNetworkActivityProtocol>)networkActivityManager{
    
    if (imageCache) {
        [[GiphyNetworkManager sharedManager] setImageCache:imageCache];
    }
    
    if (networkActivityManager) {
        [[GiphyNetworkManager sharedManager] setNetworkActivityManager:networkActivityManager];
    }
    
    GiphyListViewController *giphyListViewController = [[GiphyListViewController alloc] initWithDataManager:dataManager ? dataManager : [GiphyBasicDataManager sharedManager]
                                                                                                 imageCache:imageCache];
    return [super initWithRootViewController:giphyListViewController];
}

@end
