//
//  GiphyEngine.m
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyEngine.h"
#import <Parse/Parse.h>
#import "GiphyListViewController.h"
#import "GiphyBasicDataManager.h"
#import "GiphyNetworkManager+ASImageNode.h"
#import "GiphyNetworkManager.h"

@implementation GiphyEngine

#pragma mark - Initialize

+ (instancetype)sharedEngine{
    static dispatch_once_t onceToken;
    static GiphyEngine *sharedEngine = nil;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GiphyEngine alloc] init];
    });
    return sharedEngine;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    _dataManager = [GiphyBasicDataManager sharedManager];
    _downloadManager = [GiphyNetworkManager sharedManager];
    _networkActivityManager = (id<GiphyNetworkActivityProtocol>)[PFNetworkActivityIndicatorManager sharedManager];
}

#pragma mark - Giphy Engine

- (void)presentGiphyPickerFromController:(UIViewController*)presentationController{
    GiphyListViewController *giphyListViewController = [[GiphyListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:giphyListViewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [presentationController setModalPresentationStyle:UIModalPresentationFullScreen];
    }else{
        [presentationController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    
    [presentationController presentViewController:navigationController
                                         animated:YES
                                       completion:nil];
}

@end
