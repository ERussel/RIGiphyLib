//
//  UIImage+GiphyFilter.m
//  GiphyTest
//
//  Created by Russel on 25.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "UIImage+GiphyFilter.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (GiphyFilter)

- (UIImage*)giphy_blurImageWithRadius:(CGFloat)blur tintColor:(UIColor*)tintColor{
    // adjust blur radius if out of bounds
    if (blur < 0.0f) {
        blur = 0.0f;
    }
    
    if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    // box size should be odd integer number
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    if (tintColor) {
        // extract color components
       const CGFloat *rgba = CGColorGetComponents(tintColor.CGColor);
       int16_t r = (int16_t)(rgba[0]*255);
       int16_t g = (int16_t)(rgba[1]*255);
       int16_t b = (int16_t)(rgba[2]*255);
       int16_t a = (int16_t)(rgba[3]*255);
        
        // create tint matrix
       const int16_t tintMatrix[4 * 4] = { r, g, b, 0,
            r, g, b, 0,
            r, g, b, 0,
            0, 0, 0, a};
        
        // build divisor to keep chanell in 0..1
        int32_t divisor = 3*255;
        
        // apply tint matrix to color
        error = vImageMatrixMultiply_ARGB8888(&inBuffer, &outBuffer2, tintMatrix, divisor, NULL, NULL, 0);
        
        if (error) {
            NSLog(@"error chome %ld", error);
        }
        
        //perform convolution to make blur image
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
    }else{
        //perform convolution to make blur
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
    }
    
    // extract result image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
