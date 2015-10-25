//
//  GiphySearchRequestObject.m
//  GiphyTest
//
//  Created by Aft3rmath on 07.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "GiphySearchRequestObject.h"

@implementation GiphySearchRequestObject

#pragma mark - Initialize

- (instancetype)initWithTranslationResult:(GiphyTranslationResult *)translationResult{
    self = [super init];
    if (self) {
        _translationResult = translationResult;
    }
    return self;
}

#pragma mark - Subclass

- (BOOL)isEqualToSearchRequest:(GiphySearchRequestObject*)object{
    if (!object) {
        return NO;
    }
    
    return [self.translationResult isEqualToTranslationResult:object.translationResult];
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GiphySearchRequestObject class]]) {
        return NO;
    }
    
    return [self isEqualToSearchRequest:object];
}

- (NSUInteger)hash{
    return [self.translationResult hash];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _translationResult = [aDecoder decodeObjectForKey:@"translationResult"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (_translationResult) {
        [aCoder encodeObject:_translationResult forKey:@"translationResult"];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone{
    GiphySearchRequestObject *copySearchRequest = [[GiphySearchRequestObject alloc] init];
    copySearchRequest.translationResult = _translationResult;
    return copySearchRequest;
}

@end
