//
//  GiphyGIFObject.h
//  GiphyTest
//
//  Created by Aft3rmath on 09.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Subclass of NSObject desinged to store gif object's data.
 */
@interface GiphyGIFObject : NSObject <NSCoding, NSCopying>

/**
 *  Uniqueue gif identifier.
 */
@property(nonatomic, copy)NSString *gifId;

/**
 *  URL to download placeholder thumbnail image.
 */
@property(nonatomic, copy)NSURL *thumbnailStillURL;

/**
 *  URL to download placeholder original image.
 */
@property(nonatomic, copy)NSURL *originalStillURL;

/**
 *  URL to download thumbnail gif.
 */
@property(nonatomic, copy)NSURL *thumbnailGifURL;

/**
 *  URL to download original gif.
 */
@property(nonatomic, copy)NSURL *originalGifURL;

/**
 *  Creates gif object with default information.
 *  @param gifId                Uniqueue gif identifier.
 *  @param thumbnailStillURL    URL to download placeholder thumbnail image.
 *  @param originalStillURL     URL to download placeholder original image.
 *  @param thumbnailGifURL      URL to download thumbnail gif.
 *  @param originalGifURL       URL to download original gif.
 *  @return Initialized GIF object.
 */
- (instancetype)initWithGifId:(NSString*)gifId
              thumbnailStillURL:(NSURL*)thumbnailStillURL
             originalStillURL:(NSURL*)originalStillURL
                thumbnailGifURL:(NSURL*)thumbnailGifURL
               originalGifURL:(NSURL*)originalGifURL;

/**
 *  @return YES if content of the current GIF is the same as provided one,
 *          otherwise NO.
 */
- (BOOL)isEqualToGIF:(GiphyGIFObject*)object;


@end
