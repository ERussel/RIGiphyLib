//
//  UIView+Giphy.h
//  GiphyTest
//
//  Created by Russel on 25.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Category to add addtional methods to UIView class.
 */

@interface UIView (Giphy)

/**
 *  Render UIView to jpeg image object.
 *  @param jpegQuality  Final image's quality to apply. Value must be between 0.0f (low) and 1.0f (high)
 */
- (UIImage*)giphy_screenshotWithQuality:(CGFloat)jpegQuality;

@end
