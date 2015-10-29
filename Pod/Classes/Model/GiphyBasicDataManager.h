//
//  GiphyBasicDataManager.h
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiphyDataStoreProtocol.h"

/**
 *  Subclas of NSObject designed to provide implementation of GiphyDataStoreProtocol for internal usage data store singltone.
 */

@interface GiphyBasicDataManager : NSObject<GiphyDataStoreProtocol>

#pragma mark - Initialize

/**
 *  @return Shared datamanager object.
 */
+ (instancetype)sharedManager;

@end
