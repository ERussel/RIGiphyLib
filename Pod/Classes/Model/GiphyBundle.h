//
//  GiphyBundle.h
//  Pods
//
//  Created by Russel on 25.10.15.
//
//

#import <Foundation/Foundation.h>

@interface GiphyBundle : NSObject

/**
 Returns bundle for Giphy (by default GiphyResources)
 @return Bundle object or nil
 */
+ (NSBundle *)resourcesBundle;

/**
 Searches for image in giphy bundle
 @param name Name for image to find
 @return Founded image object or nil, if file not found
 */
+ (UIImage *)imageNamed:(NSString *)name;

/**
 * Returns localized string from giphy bundle
 */
+ (NSString *)localizedString:(NSString *)string;

@end
