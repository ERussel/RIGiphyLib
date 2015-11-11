//
//  GiphyCategoryObject+Parse.h
//  GiphyTest
//
//  Created by Russel on 13.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCategoryObject.h"
#import <Parse/Parse.h>

/**
 *  Category of GiphyCategoryObject desined to provide methods which
 *  connects GiphyCategoryObject with Parse objects.
 */
@interface GiphyCategoryObject (Parse)

/**
 *  @return Category created from Parse category object.
 */
+ (instancetype)categoryFromPFObject:(PFObject*)pfCategory;

/**
 *  @return Category created from Parse category dictionary.
 */
+ (instancetype)categoryFromDictionary:(NSDictionary*)pfCategory;

@end
