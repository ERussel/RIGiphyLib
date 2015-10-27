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

@protocol GiphyPreviewViewControllerDelegate <NSObject>
@optional

- (void)giphyPreviewControllerDidCancel:(GiphyPreviewViewController*)giphyPreviewController;

- (void)giphyPreviewController:(GiphyPreviewViewController*)giphyPreviewController didSelectGIFObject:(GiphyGIFObject*)gifObject;

@end

@interface GiphyPreviewViewController : UIViewController

@property(nonatomic, weak)id<GiphyPreviewViewControllerDelegate> delegate;

@property(nonatomic)GiphyGIFObject *gifObject;

- (instancetype)initWithGifObject:(GiphyGIFObject*)gifObject;

@end