//
//  GiphySearchRequestObject.h
//  GiphyTest
//
//  Created by Aft3rmath on 07.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiphyTranslationResult.h"

/**
 *  Subclass of NSObject designed to store gif search request.
 */
@interface GiphySearchRequestObject : NSObject <NSCoding, NSCopying>

/**
 *  Translation to use to fetch gifs (giphy supports only en).
 */
@property (nonatomic, copy)GiphyTranslationResult *translationResult;

/**
 *  Creates search request.
 *  @param translationResult Translation to use to fetch gifs (giphy supports only en).
 *  @return Initialized GiphySearchRequestObject object.
 */
- (instancetype)initWithTranslationResult:(GiphyTranslationResult*)translationResult;

#pragma - Giphy Search Request Object

/**
 *  @return YES if content of the current request is the same as provided one,
 *          otherwise NO.
 */
- (BOOL)isEqualToSearchRequest:(GiphySearchRequestObject*)object;

@end
