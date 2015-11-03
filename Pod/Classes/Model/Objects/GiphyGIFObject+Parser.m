//
//  GiphyGIFObject+Parser.m
//  GiphyTest
//
//  Created by Russel on 13.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyGIFObject+Parser.h"

@implementation GiphyGIFObject (Parser)

+ (instancetype)gifObjectFromGiphyDictionary:(NSDictionary*)giphyDictionary{
    // extract thumbnail gif's size
    CGFloat thumbnailWidth = [giphyDictionary[@"images"][@"fixed_width"][@"width"] floatValue];
    CGFloat thumbnailHeight = [giphyDictionary[@"images"][@"fixed_width"][@"height"] floatValue];
    
    // extract original gif's size
    CGFloat originalWidth = [giphyDictionary[@"images"][@"original"][@"width"] floatValue];
    CGFloat originalHeight = [giphyDictionary[@"images"][@"original"][@"height"] floatValue];
    
    return [[GiphyGIFObject alloc] initWithGifId:giphyDictionary[@"id"]
                                   thumbnailSize:CGSizeMake(thumbnailWidth, thumbnailHeight)
                                    originalSize:CGSizeMake(originalWidth, originalHeight)
                               thumbnailStillURL:[NSURL URLWithString:giphyDictionary[@"images"][@"fixed_width_still"][@"url"]]
                                originalStillURL:[NSURL URLWithString:giphyDictionary[@"images"][@"original_still"][@"url"]]
                                 thumbnailGifURL:[NSURL URLWithString:giphyDictionary[@"images"][@"fixed_width"][@"url"]]
                                  originalGifURL:[NSURL URLWithString:giphyDictionary[@"images"][@"original"][@"url"]]];
}

@end
