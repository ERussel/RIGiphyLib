//
//  GiphyNetworkActivityProtocol.h
//  GiphyTest
//
//  Created by Russel on 23.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol to control network indicator display
 */
@protocol GiphyNetworkActivityProtocol <NSObject>

/**
 *  Increments number of network operations.
 */
- (void)incrementActivityCount;

/**
 *  Decrements number of network operations.
 */
- (void)decrementActivityCount;

@end
