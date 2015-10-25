//
//  GiphyGIFObject.m
//  GiphyTest
//
//  Created by Aft3rmath on 09.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "GiphyGIFObject.h"

@implementation GiphyGIFObject

#pragma mark - Initialize

- (instancetype)initWithGifId:(NSString*)gifId
            thumbnailStillURL:(NSURL*)thumbnailStillURL
             originalStillURL:(NSURL*)originalStillURL
              thumbnailGifURL:(NSURL*)thumbnailGifURL
               originalGifURL:(NSURL*)originalGifURL{
    self = [super init];
    if (self) {
        _gifId = gifId;
        _thumbnailStillURL = thumbnailStillURL;
        _originalStillURL = originalStillURL;
        _thumbnailGifURL = thumbnailGifURL;
        _originalGifURL = originalGifURL;
    }
    return self;
}

#pragma mark - Subclass

- (BOOL)isEqualToGIF:(GiphyGIFObject*)object{
    if (!object) {
        return NO;
    }
    
    BOOL hasSameId = (!_gifId && !object.gifId) || [_gifId isEqualToString:object.gifId];
    BOOL hasSameThumbStill = (!_thumbnailStillURL && !object.thumbnailStillURL) || [_thumbnailStillURL isEqual:object.thumbnailStillURL];
    BOOL hasSameOriginalStill = (!_originalStillURL && !object.originalStillURL) || [_originalStillURL isEqual:object.originalStillURL];
    BOOL hasSameThumbGIF = (!_thumbnailGifURL && !object.thumbnailGifURL) || [_thumbnailGifURL isEqual:object.thumbnailGifURL];
    BOOL hasSameOriginalGIF = (!_originalGifURL && !object.originalGifURL) || [_originalGifURL isEqual:object.originalGifURL];
    
    return hasSameId && hasSameThumbStill && hasSameOriginalStill && hasSameThumbGIF && hasSameOriginalGIF;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GiphyGIFObject class]]) {
        return NO;
    }
    
    return [self isEqualToGIF:object];
}

- (NSUInteger)hash{
    return [_gifId hash] ^ [_thumbnailStillURL hash] ^ [_originalStillURL hash] ^ [_thumbnailGifURL hash] ^ [_originalGifURL hash];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _gifId = [aDecoder decodeObjectForKey:@"gifId"];
        _thumbnailStillURL = [aDecoder decodeObjectForKey:@"thumbnailStillURL"];
        _originalStillURL = [aDecoder decodeObjectForKey:@"originalStillURL"];
        _thumbnailGifURL = [aDecoder decodeObjectForKey:@"thumbnailGifURL"];
        _originalGifURL = [aDecoder decodeObjectForKey:@"originalGifURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (_gifId) {
        [aCoder encodeObject:_gifId forKey:@"gifId"];
    }
    
    if (_thumbnailStillURL) {
        [aCoder encodeObject:_thumbnailStillURL forKey:@"thumbnailStillURL"];
    }
    
    if (_originalStillURL) {
        [aCoder encodeObject:_originalStillURL forKey:@"originalStillURL"];
    }
    
    if (_thumbnailGifURL) {
        [aCoder encodeObject:_thumbnailGifURL forKey:@"thumbnailGifURL"];
    }
    
    if (_originalGifURL) {
        [aCoder encodeObject:_originalGifURL forKey:@"originalGifURL"];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone{
    GiphyGIFObject *copyGIFObject = [[GiphyGIFObject alloc] init];
    copyGIFObject.gifId = _gifId;
    copyGIFObject.thumbnailStillURL = _thumbnailStillURL;
    copyGIFObject.originalStillURL = _originalStillURL;
    copyGIFObject.thumbnailGifURL = _thumbnailGifURL;
    copyGIFObject.originalGifURL = _originalGifURL;
    return copyGIFObject;
}

@end
