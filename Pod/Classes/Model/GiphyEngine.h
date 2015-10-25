//
//  GiphyEngine.h
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "GiphyImageCacheProtocol.h"
#import "GiphyDataStoreProtocol.h"
#import "GiphyNetworkActivityProtocol.h"

@interface GiphyEngine : NSObject<UIViewControllerTransitioningDelegate>

+ (instancetype)sharedEngine;

@property(nonatomic, readonly)id<GiphyDataStoreProtocol> dataManager;
@property(nonatomic)id<GiphyImageCacheProtocol> cacheManager;
@property(nonatomic)id<ASImageDownloaderProtocol> downloadManager;
@property(nonatomic)id<GiphyNetworkActivityProtocol> networkActivityManager;

- (void)presentGiphyPickerFromController:(UIViewController*)presentationController;

@end
