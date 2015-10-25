//
//  GiphyBundle.m
//  Pods
//
//  Created by Russel on 25.10.15.
//
//

#import "GiphyBundle.h"

@implementation GiphyBundle

+ (NSBundle *)resourcesBundle{
    static dispatch_once_t onceToken;
    static NSBundle *resourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        NSString *fileName = @"GiphyResources";
        NSString *ext = @"bundle";
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:ext];
        if (url) {
            resourcesBundle = [NSBundle bundleWithURL:url];
        }
    });
    return resourcesBundle;
}

+ (UIImage *)imageNamed:(NSString *)name{
    @autoreleasepool {
        NSString *imageName = [name stringByDeletingPathExtension];
        NSString *extension = [name pathExtension];
        UIImage *imageFromMyLibraryBundle = [UIImage imageWithContentsOfFile:[[self resourcesBundle] pathForResource:imageName ofType:extension]];
        return imageFromMyLibraryBundle;
    }
}

+ (NSString *)localizedString:(NSString *)string {
    return [[self resourcesBundle] localizedStringForKey:string value:string table:nil];
}

@end
