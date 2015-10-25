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
    return [[GiphyGIFObject alloc] initWithGifId:giphyDictionary[@"id"]
                               thumbnailStillURL:[NSURL URLWithString:giphyDictionary[@"images"][@"fixed_width_still"][@"url"]]
                                originalStillURL:[NSURL URLWithString:giphyDictionary[@"images"][@"original_still"][@"url"]]
                                 thumbnailGifURL:[NSURL URLWithString:giphyDictionary[@"images"][@"fixed_width"][@"url"]]
                                  originalGifURL:[NSURL URLWithString:giphyDictionary[@"images"][@"original"][@"url"]]];
}

@end
