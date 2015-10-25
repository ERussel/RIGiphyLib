//
//  GiphyTranslationResult.h
//  GiphyTest
//
//  Created by Russel on 09.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Subclass of NSObject designed to store text's translation result.
 */
@interface GiphyTranslationResult : NSObject<NSCoding, NSCopying>

/**
 *  NSString text to translate.
 */
@property(nonatomic, copy)NSString *originalText;

/**
 *  NSArray of NSString representing possible translations.
 */
@property(nonatomic, copy)NSArray *results;

/**
 *  NSString representing the most suitable translation.
 *
 *  By default, first object of the results array.
 */
@property(nonatomic, copy)NSString *translatedText;

/**
 *  NSString language ISO code, original text translated from.
 */
@property(nonatomic, copy)NSString *originalLanguage;

/**
 *  NSString language ISO code, original text translated to.
 */
@property(nonatomic, copy)NSString *resultLanguage;

/**
 *  Creates translation result object.
 *  @param results              NSArray of NSString representing possible translations.
 *  @param originalText         NSString text to translate.
 *  @param originalLanguage     NSString language ISO code, original text translated from.
 *  @param resultLanguage       NSString language ISO code, original text translated to.
 *  @return Initialized GiphyTranslationResult.
 */
- (instancetype)initWithResults:(NSArray*)results
                forOriginalText:(NSString*)originalText
         translatedFromLanguage:(NSString*)originalLanguage
                     toLanguage:(NSString*)resultLanguage;

/**
 *  @return YES if content of the current translation result is the same as provided one,
 *          otherwise NO.
 */
- (BOOL)isEqualToTranslationResult:(GiphyTranslationResult*)object;

@end
