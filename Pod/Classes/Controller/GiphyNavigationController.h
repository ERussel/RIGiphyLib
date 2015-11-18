//
//  GiphyNavigationController.h
//  Pods
//
//  Created by Russel on 25.10.15.
//
//

#import <UIKit/UIKit.h>
#import "GiphyObjectCacheProtocol.h"
#import "GiphyDataStoreProtocol.h"
#import "GiphyNetworkActivityProtocol.h"
#import "GiphyGIFObject.h"

/**
 *  Notification name which would post when user closes giphy controller.
 */
extern NSString * const GiphyNavigationControllerDidCancelNotification;

/**
 *  Notification name which would post when user selects GIF object.
 */
extern NSString * const GiphyNavigationControllerDidSelectGIFNotification;

/**
 *  Key to extract GIF object from notification's user info.
 */
extern NSString * const kGiphyNotificationGIFObjectKey;

@class GiphyNavigationController;

/**
 *  Protocol to notify about actions and events inside giphy controller.
 */

@protocol GiphyNavigationControllerDelegate <UINavigationControllerDelegate>

/**
 *  Notifies delegate that user selected GIF object.
 *  @param giphyNavigationController    Giphy controller action occured inside.
 *  @param gifObject                    GIF object selected by the user.
 */
- (void)giphyNavigationController:(GiphyNavigationController *)giphyNavigationController
               didSelectGIFObject:(GiphyGIFObject*)gifObject;

@optional

/**
 *  Notifies delegate that user closed giphy controller without selection.
 */
- (void)giphyNavigationControllerDidCancel:(GiphyNavigationController*)giphyNavigationController;

@end

/**
 *  Subclass of UINavigationController designed to present GIF selection interface.
 *  By default category list is visible and user has 2 options: start GIF search by selecting category or enter search phrase.
 *  Because Giphy supports only english requests, search phrase automatically translated from input language.
 *
 *  <b> Sample using </b>
 *
 *  \code GiphyNavigationController *giphyController = [[GiphyNavigationController alloc] initWithCache:<replace with custom cache or nil>
 *                                                                                              dataManager:<replace with custom store or nil>
 *                                                                                  networkActivityManager:<replace with custom manager or nil>];
 * giphyController.delegate = self;
 * [self presentViewController:giphyController animated:YES completion:nil];
 *  \endcode
 *
 * <b>Cache</b>
 *
 *  To enable gif and stills caching, pass object conforming to <a>GiphyImageCacheProtocol</a> protocol to initialization method.
 *  \sa GiphyImageCacheProtocol
 */

@interface GiphyNavigationController : UINavigationController

/**
 *  Creates giphy controller.
 *  @param objectCache  Object which conforms GiphyObjectCacheProtocol to cache GIF and stills.
 *                      By default no cache will be used.
 *  @param dataManager  Object which conforms GiphyDataStoreProtocol to save giphy related data
 *                      (for example, user's search requests to display history). Basic datamanger will be used
 *                      by default.
 *  @param networkActivityManager   Object which conforms GiphyNetworkActivityProtocol to manage shared network indicator
 *                                  visibility. By default PFNetworkActivityIndicatorManager will be used.
 */
- (instancetype)initWithCache:(id<GiphyObjectCacheProtocol>)objectCache
                         dataManager:(id<GiphyDataStoreProtocol>)dataManager
                    networkActivityManager:(id<GiphyNetworkActivityProtocol>)networkActivityManager;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController __attribute__ ((unavailable));

- (instancetype)init __attribute__ ((unavailable));

/**
 *  Delegate object to notify about actions and events in giphy controller.
 */
@property(nonatomic, weak)id<GiphyNavigationControllerDelegate> delegate;

/**
 *  Flags states whether user can cancel GIF selection.
 *  By default <b>NO</b>.
 */
@property(nonatomic, readwrite)BOOL hidesCancelButton;

/**
 *  Flag states whether thumb GIF should be loaded to display in cell.
 *  By default <b>NO</b>.
 */
@property(nonatomic, readwrite)BOOL ignoresGIFPreloadForCell;

/**
 *  Flag states whether high quality still should be loaded as placeholder in cell.
 *  By default <b>NO</b> and low qulity placeholders will be loaded.
 */
@property(nonatomic, readwrite)BOOL usesOriginalStillAsPlaceholder;

/**
 *  Color to draw cell placeholders while still and GIF loading.
 *  By default light gray color.
 */
@property(nonatomic)UIColor *cellPlaceholderColor;

/**
 *  Color to generate blur background for GIF preview.
 *  By default gray color.
 */
@property(nonatomic)UIColor *previewBlurColor;

@end
