//
//  GiphyCategoryObject+Parse.m
//  GiphyTest
//
//  Created by Russel on 13.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCategoryObject+Parse.h"

@implementation GiphyCategoryObject (Parse)

+ (instancetype)categoryFromPFObject:(PFObject*)pfCategory{
    return [[GiphyCategoryObject alloc] initWithCategoryId:pfCategory.objectId
                                                    titles:pfCategory[@"titles"]
                                                  stillURL:[NSURL URLWithString:pfCategory[@"stillURLString"]]
                                                 andGifURL:[NSURL URLWithString:pfCategory[@"smallGIFURLString"]]];
}

@end
