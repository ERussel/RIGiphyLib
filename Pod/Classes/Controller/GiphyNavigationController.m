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

@interface GiphyNavigationController ()

#pragma mark - Initialize

/**
 *  Provides initial setup.
 */
- (void)defaultInit;

#pragma mark - Notification

/**
 *  Invoked when user wants to close controller without picking GIF.
 *  By default notifies delegate and dismiss controller.
 *  @param notification Notification object posted to close controller.
 */
- (void)notificationDidCancel:(NSNotification*)notification;

/**
 *  Invoked when user selects GIF.
 *  By default notifies delegate, but controlled would not be closed.
 *  @param notification Notification object posted when GIF selected. User info will contain GIF object.
 */
- (void)notificationDidSelectGIF:(NSNotification*)notification;

@end

@implementation GiphyNavigationController
@synthesize delegate;

#pragma mark - Memory

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialize

- (instancetype)initWithNetworkConfiguration:(GiphyNetworkManagerConfiguration*)config
                                       cache:(id<GiphyObjectCacheProtocol>)objectCache
                                 dataManager:(id<GiphyDataStoreProtocol>)dataManager
                      networkActivityManager:(id<GiphyNetworkActivityProtocol>)networkActivityManager{
    if (![GiphyNetworkManager isInitialized]) {
        [GiphyNetworkManager initializeWithConfiguration:config];
    }
    
    if (objectCache) {
        [[GiphyNetworkManager sharedManager] setObjectCache:objectCache];
    }
    
    if (networkActivityManager) {
        [[GiphyNetworkManager sharedManager] setNetworkActivityManager:networkActivityManager];
    }
    
    GiphyListViewController *giphyListViewController = [[GiphyListViewController alloc] initWithDataManager:dataManager ? dataManager : [GiphyBasicDataManager sharedManager]];
    self = [super initWithRootViewController:giphyListViewController];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        GiphyListViewController *giphyListViewController = [[GiphyListViewController alloc] initWithDataManager:[GiphyBasicDataManager sharedManager]];
        [self setViewControllers:@[giphyListViewController]];
        
        [self defaultInit];
    }
    return self;
}

- (void)awakeFromNib{
    GiphyListViewController *giphyListViewController = [[GiphyListViewController alloc] initWithDataManager:[GiphyBasicDataManager sharedManager]];
    [self setViewControllers:@[giphyListViewController]];
    
    [self defaultInit];
}

- (void)defaultInit{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidCancel:)
                                                 name:GiphyNavigationControllerDidCancelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidSelectGIF:)
                                                 name:GiphyNavigationControllerDidSelectGIFNotification
                                               object:nil];
}

#pragma mark - Giphy Navigation Controller

- (BOOL)shouldAutorotate{
    // block autorotation only when preview controller presented
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
