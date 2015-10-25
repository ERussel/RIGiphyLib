//
//  UIImage+GiphyFilter.h
//  GiphyTest
//
//  Created by Russel on 25.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Category to apply filters to image.
 */

@interface UIImage (GiphyFilter)

/**
 *  Creates blured monochrome image.
 *  @param blur         Blur value to apply to the image (between 0.0f and 1.0f).
 *  @param tintColor    Tint color to apply to the image. If this value is nil than blur only applied.
 *  @return Blured monochrome image.
 */
- (UIImage*)giphy_blurImageWithRadius:(CGFloat)blur tintColor:(UIColor*)tintColor;

@end
