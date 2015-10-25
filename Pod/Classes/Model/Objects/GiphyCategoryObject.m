//
//  GiphyCategoryObject.m
//  GiphyTest
//
//  Created by Aft3rmath on 24.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCategoryObject.h"

@implementation GiphyCategoryObject

#pragma mark - Initialized

- (instancetype)initWithCategoryId:(NSString*)categoryId
                            titles:(NSDictionary*)titles
                          stillURL:(NSURL*)stillURL
                         andGifURL:(NSURL*)gifURL{
    self = [super init];
    if (self) {
        _categoryId = categoryId;
        _titles = titles;
        _stillURL = stillURL;
        _gifURL = gifURL;
    }
    return self;
}

#pragma mark - Subclass

- (BOOL)isEqualToCategory:(GiphyCategoryObject *)object{
    if (!object) {
        return NO;
    }
    
    BOOL hasSameCategoryId = (!_categoryId && !object.categoryId) || [_categoryId isEqualToString:object.categoryId];
    BOOL hasSameTitles = (!_titles && !object.titles) || [_titles isEqualToDictionary:object.titles];
    BOOL hasSameStillURL = (!_stillURL && !object.stillURL) || [_stillURL isEqual:object.stillURL];
    BOOL hasSameGifURL = (!_gifURL && !object.gifURL) || [_gifURL isEqual:object.gifURL];
    
    return hasSameCategoryId && hasSameTitles && hasSameStillURL && hasSameGifURL;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GiphyCategoryObject class]]) {
        return NO;
    }
    
    return [self isEqualToCategory:object];
}

- (NSUInteger)hash{
    return [_categoryId hash] ^ [_titles hash] ^ [_stillURL hash] ^ [_gifURL hash];
}

#pragma mark - Giphy Object

- (NSString*)enLocalizedTitle{
    return [self titleForLocaleCode:@"en"];
}

- (NSString *)localizedTitle{
    NSString *currentLanguage = [[NSLocale preferredLanguages] count] > 0 ? [[NSLocale preferredLanguages] firstObject] : nil;
    if(currentLanguage && [[_titles allKeys] containsObject:currentLanguage]) {
        return [_titles objectForKey:currentLanguage];
    }
    
    currentLanguage = [[[NSBundle mainBundle] preferredLocalizations] count] > 0 ? [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] : nil;
    if(currentLanguage && [[_titles allKeys] containsObject:currentLanguage]) {
        return [_titles objectForKey:currentLanguage];
    }
    
    return [_titles objectForKey:@"en"];
}

- (NSString*)titleForLocaleCode:(NSString *)localeCode{
    return [_titles objectForKey:localeCode];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
        _titles = [aDecoder decodeObjectForKey:@"titles"];
        _stillURL = [aDecoder decodeObjectForKey:@"stillURL"];
        _gifURL = [aDecoder decodeObjectForKey:@"gifURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (_categoryId) {
        [aCoder encodeObject:_categoryId forKey:@"categoryId"];
    }
    
    if (_titles) {
        [aCoder encodeObject:_titles forKey:@"titles"];
    }
    
    if (_stillURL) {
        [aCoder encodeObject:_stillURL forKey:@"stillURL"];
    }
    
    if (_gifURL) {
        [aCoder encodeObject:_gifURL forKey:@"gifURL"];
    }
}

#pragma mark - NSCoping

- (instancetype)copyWithZone:(NSZone *)zone{
    GiphyCategoryObject *copyCategoryObject = [[GiphyCategoryObject alloc] init];
    copyCategoryObject.categoryId = _categoryId;
    copyCategoryObject.titles = _titles;
    copyCategoryObject.stillURL = _stillURL;
    copyCategoryObject.gifURL = _gifURL;
    return copyCategoryObject;
}

@end
