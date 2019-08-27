//
//  GiphyNetworkManagerConfiguration.m
//  Pods
//
//  Created by Russel on 22.03.17.
//
//

#import "GiphyNetworkManagerConfiguration.h"

@implementation GiphyNetworkManagerConfiguration

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    GiphyNetworkManagerConfiguration *copyConfig = [[[self class] alloc] init];
    copyConfig.categoryUrl = self.categoryUrl;
    return copyConfig;
}

@end
