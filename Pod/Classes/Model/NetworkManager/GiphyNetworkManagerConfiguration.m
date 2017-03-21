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
    copyConfig.parseServer = self.parseServer;
    copyConfig.parseApplicationId = self.parseApplicationId;
    copyConfig.parseClientKey = self.parseClientKey;
    copyConfig.categoryPath = self.categoryPath;
    return copyConfig;
}

@end
