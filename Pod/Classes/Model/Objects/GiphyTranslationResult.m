//
//  GiphyTranslationResult.m
//  GiphyTest
//
//  Created by Russel on 09.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyTranslationResult.h"

@implementation GiphyTranslationResult

#pragma mark - Initialize

- (instancetype)initWithResults:(NSArray*)results
                forOriginalText:(NSString*)originalText
         translatedFromLanguage:(NSString*)originalLanguage
                     toLanguage:(NSString*)resultLanguage{
    self = [super init];
    if (self) {
        _results = results;
        _originalText = originalText;
        _originalLanguage = originalLanguage;
        _resultLanguage = resultLanguage;
    }
    return self;
}

#pragma mark - Subclass

- (BOOL)isEqualToTranslationResult:(GiphyTranslationResult*)object{
    if (!object) {
        return NO;
    }
    
    BOOL haveSameOriginalText = (!_originalText && !object.originalText) || [_originalText isEqualToString:object.originalText];
    BOOL haveSameOriginalLanguage = (!_originalLanguage && !object.originalLanguage) || [_originalLanguage isEqualToString:object.originalLanguage];
    BOOL haveSameResults = (!_results && !object.results) || [_results isEqualToArray:object.results];
    BOOL haveSameResultLanguage = (!_resultLanguage && !object.resultLanguage) || [_resultLanguage isEqualToString:object.resultLanguage];
    
    return haveSameOriginalText && haveSameOriginalLanguage && haveSameResults && haveSameResultLanguage;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GiphyTranslationResult class]]) {
        return NO;
    }
    
    return [self isEqualToTranslationResult:object];
}

- (NSUInteger)hash{
    return [_originalText hash] ^ [_originalLanguage hash] ^ [_results hash] ^ [_resultLanguage hash];
}

#pragma mark - Translation Result

- (NSString*)translatedText{
    return [_results count] > 0 ? [_results firstObject] : nil;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _results = [aDecoder decodeObjectForKey:@"results"];
        _originalText = [aDecoder decodeObjectForKey:@"originalText"];
        _originalLanguage = [aDecoder decodeObjectForKey:@"originalLanguage"];
        _resultLanguage = [aDecoder decodeObjectForKey:@"resultLanguage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (_results) {
        [aCoder encodeObject:_results forKey:@"results"];
    }
    
    if (_originalText) {
        [aCoder encodeObject:_originalText forKey:@"originalText"];
    }
    
    if (_originalLanguage) {
        [aCoder encodeObject:_originalLanguage forKey:@"originalLanguage"];
    }
    
    if (_resultLanguage) {
        [aCoder encodeObject:_resultLanguage forKey:@"resultLanguage"];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone{
    GiphyTranslationResult *copyTranslationResult = [[GiphyTranslationResult alloc] init];
    copyTranslationResult.results = _results;
    copyTranslationResult.originalText = _originalText;
    copyTranslationResult.originalLanguage = _originalLanguage;
    copyTranslationResult.resultLanguage = _resultLanguage;
    return copyTranslationResult;
}

@end
