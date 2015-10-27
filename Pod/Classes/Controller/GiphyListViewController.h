//
//  GiphyListViewController.h
//  GiphyTest
//
//  Created by Russel on 15.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyDataStoreProtocol.h"
#import "GiphyImageCacheProtocol.h"

@interface GiphyListViewController : UIViewController

- (instancetype)initWithDataManager:(id<GiphyDataStoreProtocol>)dataManager imageCache:(id<GiphyImageCacheProtocol>)imageCache;

@property(nonatomic, readwrite)BOOL hidesCancelButton;

@property(nonatomic, readwrite)BOOL ignoresGIFPreloadForCell;

@property(nonatomic, readwrite)BOOL usesOriginalStillAsPlaceholder;

@property(nonatomic)UIColor *cellPlaceholderColor;

@property(nonatomic)UIColor *previewBlurColor;

@end
