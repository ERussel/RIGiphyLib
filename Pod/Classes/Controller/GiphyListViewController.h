//
//  GiphyListViewController.h
//  GiphyTest
//
//  Created by Russel on 15.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyDataStoreProtocol.h"

/**
 *  Subclass of UIViewController designed to provide GIF service interface, including
 *  category -> GIFs navigation, GIF search, search history display. GIFs are displayed in collection view
 *  with portrait/landscape orientation support.
 */
@interface GiphyListViewController : UIViewController

/**
 *  Creates GIF list view controller.
 *  @param dataManager  Data manager to save related data such as search requests.
 *  @return Initialized GIF list view controller.
 */
- (instancetype)initWithDataManager:(id<GiphyDataStoreProtocol>)dataManager;

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
