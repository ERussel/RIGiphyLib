//
//  GiphyCategoryObject.h
//  GiphyTest
//
//  Created by Aft3rmath on 24.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Subclass of NSObject designed to store gif category's information.
 */
@interface GiphyCategoryObject : NSObject <NSCopying, NSCoding>

/**
 *  Unique category's identifier.
 */
@property(nonatomic, copy)NSString *categoryId;

/**
 *  NSDictionary representing correspondence between locale code and title.
 */
@property (nonatomic, copy)NSDictionary *titles;

/**
 *  URL to image representing category.
 */
@property (nonatomic, copy)NSURL *stillURL;

/**
 *  URL to gif representing category.
 */
@property (nonatomic, copy)NSURL *gifURL;

/**
 *  @return title corresponding to current localization.
 */
@property (nonatomic, readonly)NSString *localizedTitle;

/**
 *  @return title for English localization
 */
@property (nonatomic, readonly)NSString *enLocalizedTitle;

/**
 *  Initialize gif category.
 *  @param category Unique category's identifier.
 *  @param titles   NSDictionary representing correspondence between locale code and title.
 *  @param stillURL URL to image representing category.
 *  @param gifURL   URL to gif representing category.
 */
- (instancetype)initWithCategoryId:(NSString*)categoryId
                            titles:(NSDictionary*)titles
                        stillURL:(NSURL*)stillURL
                   andGifURL:(NSURL*)gifURL;

/**
 *  @return YES if content of the current category is the same as provided one,
 *          otherwise NO.
 */
- (BOOL)isEqualToCategory:(GiphyCategoryObject*)object;

/**
 *  @return title corresponding to provided localization
 */
- (NSString*)titleForLocaleCode:(NSString*)localeCode;

@end
