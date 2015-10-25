//
//  GiphyGIFObject+Parser.h
//  GiphyTest
//
//  Created by Russel on 13.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyGIFObject.h"

/**
 *  Category of GiphyGIFObject designed to provide parsing methods from different formats.
 */

@interface GiphyGIFObject (Parser)

/**
 *  @return Gif object created from giphy dictionary format.
 */
+ (instancetype)gifObjectFromGiphyDictionary:(NSDictionary*)giphyDictionary;

@end
