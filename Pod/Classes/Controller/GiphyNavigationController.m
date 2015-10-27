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

NSString * const GiphyNavigationControllerDidCancelNotification = @"GiphyNavigationControllerDidCancelNotification";
NSString * const GiphyNavigationControllerDidSelectGIFNotification = @"GiphyNavigationControllerDidSelectGIFNotification";
NSString * const kGiphyNotificationGIFObjectKey = @"GiphyNotificationGIFObjectKey";

@implementation GiphyNavigationController
@synthesize delegate;

#pragma mark - Memory

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialize

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
    self = [super initWithRootViewController:giphyListViewController];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationDidCancel:)
                                                     name:GiphyNavigationControllerDidCancelNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationDidSelectGIF:)
                                                     name:GiphyNavigationControllerDidSelectGIFNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Giphy Navigation Controller

- (BOOL)shouldAutorotate{
    if (self.presentedViewController) {
        return NO;
    }else{
        return YES;
    }
}

- (void)setHidesCancelButton:(BOOL)hidesCancelButton{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    [listViewController setHidesCancelButton:hidesCancelButton];
}

- (BOOL)hidesCancelButton{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    return listViewController.hidesCancelButton;
}

- (void)setIgnoresGIFPreloadForCell:(BOOL)ignoresGIFPreloadForCell{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    [listViewController setIgnoresGIFPreloadForCell:ignoresGIFPreloadForCell];
}

- (BOOL)ignoresGIFPreloadForCell{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    return listViewController.ignoresGIFPreloadForCell;
}

- (void)setUsesOriginalStillAsPlaceholder:(BOOL)usesOriginalStillAsPlaceholder{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    [listViewController setUsesOriginalStillAsPlaceholder:usesOriginalStillAsPlaceholder];
}

- (BOOL)usesOriginalStillAsPlaceholder{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    return listViewController.usesOriginalStillAsPlaceholder;
}

- (void)setPreviewBlurColor:(UIColor *)previewBlurColor{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    [listViewController setPreviewBlurColor:previewBlurColor];
}

- (UIColor*)previewBlurColor{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    return listViewController.previewBlurColor;
}

- (void)setCellPlaceholderColor:(UIColor *)cellPlaceholderColor{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    [listViewController setCellPlaceholderColor:cellPlaceholderColor];
}

- (UIColor*)cellPlaceholderColor{
    GiphyListViewController *listViewController = [self.viewControllers firstObject];
    return listViewController.cellPlaceholderColor;
}

#pragma mark - Notification

- (void)notificationDidCancel:(NSNotification*)notification{
    if ([self.delegate respondsToSelector:@selector(giphyNavigationControllerDidCancel:)]) {
        [self.delegate giphyNavigationControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)notificationDidSelectGIF:(NSNotification*)notification{
    [self.delegate giphyNavigationController:self didSelectGIFObject:[notification.userInfo objectForKey:kGiphyNotificationGIFObjectKey]];
}

@end
