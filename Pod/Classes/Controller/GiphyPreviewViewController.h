//
//  GiphyPreviewViewController.h
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyGIFObject.h"

@class GiphyPreviewViewController;

/**
 *  Protocol designied to notify delegate about changes and action inside preview controller.
 */
@protocol GiphyPreviewViewControllerDelegate <NSObject>
@optional

/**
 *  Called when user closed preview controller and didn't select GIF.
 *  @param giphyPreviewController   Preview controller action occured in.
 */
- (void)giphyPreviewControllerDidCancel:(GiphyPreviewViewController*)giphyPreviewController;

/**
 *  Called when user selected GIF to use outside the service.
 *  @param giphyPreviewController   Preview controller action occured in.
 */
- (void)giphyPreviewController:(GiphyPreviewViewController*)giphyPreviewController didSelectGIFObject:(GiphyGIFObject*)gifObject;

@end

/**
 *  Subclass of UIViewController designed to display GIF preview before making decision to select it.
 */
@interface GiphyPreviewViewController : UIViewController

/**
 *  Delegate to notify about changes and action via <a>GiphyPreviewViewControllerDelegate</a>
 */
@property(nonatomic, weak)id<GiphyPreviewViewControllerDelegate> delegate;

/**
 *  GIF object to display preview for.
 */
@property(nonatomic)GiphyGIFObject *gifObject;

/**
 *  @return Preview controller initialized with GIF object.
 */
- (instancetype)initWithGifObject:(GiphyGIFObject*)gifObject;

@end