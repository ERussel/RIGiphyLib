//
//  UIView+Giphy.m
//  GiphyTest
//
//  Created by Russel on 25.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "UIView+Giphy.h"

@implementation UIView (Giphy)

- (UIImage*)giphy_screenshotWithQuality:(CGFloat)jpegQuality{
    // adjust jpeg quality if out of bounds
    if (jpegQuality < 0.0f) {
        jpegQuality = 0.0f;
    }
    
    if (jpegQuality > 1.0f) {
        jpegQuality = 1.0f;
    }
    
    // create image by rendering view
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // adjusting quality
    NSData *imageData = UIImageJPEGRepresentation(image, jpegQuality);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end
