//
//  FLAnimatedImageSerializer.m
//  GiphyTest
//
//  Created by Aft3rmath on 20.08.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "FLAnimatedImageSerializer.h"

@implementation FLAnimatedImageSerializer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/gif", nil];
    }
    
    return self;
}

+ (NSSet *)acceptablePathExtensions {
    static NSSet * _acceptablePathExtension = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _acceptablePathExtension = [[NSSet alloc] initWithObjects:@"gif", nil];
    });
    
    return _acceptablePathExtension;
}


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error] && [(NSError *)(*error) code] == NSURLErrorCannotDecodeContentData) {
        return nil;
    }
    return [FLAnimatedImage animatedImageWithGIFData:data];
}

@end
