//
//  GiphyBasicDataManager.h
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiphyDataStoreProtocol.h"

extern NSString * const kGiphyDataManagerSearchRequestCollectionName;

@interface GiphyBasicDataManager : NSObject<GiphyDataStoreProtocol>

#pragma mark - Initialize

+ (instancetype)sharedManager;

@end
