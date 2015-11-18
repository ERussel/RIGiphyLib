//
//  FLAnimatedImage+NSCoding.m
//  Pods
//
//  Created by Russel on 18.11.15.
//
//

#import "FLAnimatedImage+NSCoding.h"

@implementation FLAnimatedImage (NSCoding)

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSData *data = [aDecoder decodeObjectForKey:@"data"];
    return [self initWithAnimatedGIFData:data];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (self.data) {
        [aCoder encodeObject:self.data forKey:@"data"];
    }
}

@end
