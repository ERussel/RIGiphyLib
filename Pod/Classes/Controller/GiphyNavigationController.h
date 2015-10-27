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
#import "GiphyGIFObject.h"

extern NSString * const GiphyNavigationControllerDidCancelNotification;
extern NSString * const GiphyNavigationControllerDidSelectGIFNotification;
extern NSString * const kGiphyNotificationGIFObjectKey;

@class GiphyNavigationController;

@protocol GiphyNavigationControllerDelegate <UINavigationControllerDelegate>

- (void)giphyNavigationController:(GiphyNavigationController *)giphyNavigationController
               didSelectGIFObject:(GiphyGIFObject*)gifObject;

@optional

- (void)giphyNavigationControllerDidCancel:(GiphyNavigationController*)giphyNavigationController;

@end

@interface GiphyNavigationController : UINavigationController

- (instancetype)initWithImageCache:(id<GiphyImageCacheProtocol>)imageCache
                         dataManager:(id<GiphyDataStoreProtocol>)dataManager
                    networkActivityManager:(id<GiphyNetworkActivityProtocol>)networkActivityManager;

@property(nonatomic, weak)id<GiphyNavigationControllerDelegate> delegate;

@property(nonatomic, readwrite)BOOL hidesCancelButton;

@property(nonatomic, readwrite)BOOL ignoresGIFPreloadForCell;

@property(nonatomic, readwrite)BOOL usesOriginalStillAsPlaceholder;

@property(nonatomic)UIColor *cellPlaceholderColor;

@property(nonatomic)UIColor *previewBlurColor;

@end
