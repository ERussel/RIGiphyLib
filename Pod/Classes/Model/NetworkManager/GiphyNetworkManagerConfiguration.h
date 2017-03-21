//
//  GiphyNetworkManagerConfiguration.h
//  Pods
//
//  Created by Russel on 22.03.17.
//
//

#import <Foundation/Foundation.h>

@interface GiphyNetworkManagerConfiguration : NSObject<NSCopying>

/**
 *  Application's id registered on server.
 */
@property(nonatomic, copy)NSString *parseApplicationId;

/**
 *  Application's key to access server's data.
 */
@property(nonatomic, copy)NSString *parseClientKey;

/**
 *  Base Parse server URL
 */
@property(nonatomic, copy)NSString *parseServer;

/**
 *  Path to access categories table
 */
@property(nonatomic, copy)NSString *categoryPath;

@end
