//
//  GiphyCollectionViewNode.m
//  GiphyTest
//
//  Created by Russel on 16.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCollectionViewNode.h"
#import "GiphyCollectionViewNode_Subclass.h"
#import "GiphyNetworkManager+ASImageNode.h"

@interface GiphyCollectionViewNode ()<ASNetworkImageNodeDelegate>

@end

@implementation GiphyCollectionViewNode

#pragma mark - Memory

- (void)dealloc{
    // cancel placeholder image downloading
    [_placeholderImageNode setURL:nil];
    
    // cancel GIF download
    if (_gifCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_gifCancellationToken];
        _gifCancellationToken = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialize

- (instancetype)initWithStillURL:(NSURL*)stillURL
                      imageCache:(id<ASImageCacheProtocol>)imageCache
                          gifURL:(NSURL*)gifURL
                   preferredSize:(CGSize)preferredSize{
    self = [super init];
    if (self) {
        _gifURL = gifURL;
        _stillURL = stillURL;
        _preferredSize = preferredSize;
        
        [self configure];
        [self configurePlaceholderImageNodeWithImageCache:imageCache];
        [self configureGifNode];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configure];
        [self configurePlaceholderImageNodeWithImageCache:nil];
        [self configureGifNode];
    }
    return self;
}

- (void)configure{
    // setup default style
    _placeholderColor = [UIColor lightGrayColor];
    self.backgroundColor = _placeholderColor;
    
    _contentEmpty = YES;
    
    // listen image downloading notification to fade on completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationStillDidDownload:)
                                                 name:GiphyNetworkManagerDidRecieveStillNotification
                                               object:nil];
}

- (void)configurePlaceholderImageNodeWithImageCache:(id<ASImageCacheProtocol>)imageCache{
    ASNetworkImageNode *placeholderImageNode = [[ASNetworkImageNode alloc] initWithCache:imageCache
                                                                              downloader:[GiphyNetworkManager sharedManager]];
    placeholderImageNode.delegate = self;
    [placeholderImageNode setURL:_stillURL resetToDefault:YES];
    [self addSubnode:placeholderImageNode];
    _placeholderImageNode = placeholderImageNode;
}

- (void)configureGifNode{
    ASDisplayNode *gifDisplayNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView*{
        FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
        [animatedImageView setContentMode:UIViewContentModeScaleAspectFill];
        return animatedImageView;
    }];
    [gifDisplayNode setClipsToBounds:YES];
    [self addSubnode:gifDisplayNode];
    _gifDisplayNode = gifDisplayNode;
}

#pragma mark - Collection View Node

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    if (![_placeholderColor isEqual:placeholderColor]) {
        _placeholderColor = placeholderColor;
        [self updateLoadingState];
    }
}

#pragma mark - Subclass

- (void)didLoad{
    [super didLoad];
    
    [self fetchData];
}

- (void)fetchData{
    [super fetchData];
    
    if (!self.gifCancellationToken && _gifURL) {
        __weak __typeof(self) weakSelf = self;
        self.gifCancellationToken = [[GiphyNetworkManager sharedManager] getGIFByURL:_gifURL
                                                                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                                        successBlock:^(FLAnimatedImage *animatedImage){
            if (weakSelf.gifCancellationToken) {
                weakSelf.gifCancellationToken = nil;
                
                [(FLAnimatedImageView*)[weakSelf.gifDisplayNode view] setAnimatedImage:animatedImage];
                weakSelf.contentEmpty = NO;
                [weakSelf updateLoadingState];
            }
        } progressBlock:nil failureBlock:^(NSError *error){
            weakSelf.gifCancellationToken = nil;
        }];
    }
}

- (void)clearFetchedData{
    [super clearFetchedData];
    
    if (self.gifCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:self.gifCancellationToken];
        self.gifCancellationToken = nil;
    }
    
    [(FLAnimatedImageView*)[self.gifDisplayNode view] setAnimatedImage:nil];
    
    _contentEmpty = YES;
    _animateStillOnLoading = NO;
    [self updateLoadingState];
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize{
    return CGSizeMake(MIN(constrainedSize.width, _preferredSize.width), MIN(constrainedSize.height, _preferredSize.height));
}

- (void)layout{
    [super layout];
    
    _placeholderImageNode.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, self.calculatedSize.height);
    _gifDisplayNode.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, self.calculatedSize.height);
}

#pragma mark - Network Image Node Delegate

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image{
    if (_animateStillOnLoading) {
        _animateStillOnLoading = NO;
        
        // fade downloaded image
        _placeholderImageNode.alpha = 0.0f;
        [UIView animateWithDuration:0.35f
                              delay:0.0f
                            options:0 animations:^{
                                _placeholderImageNode.alpha = 1.0f;
                                
                                self.contentEmpty = NO;
                                [self updateLoadingState];
                            } completion:nil];
    }else{
        self.contentEmpty = NO;
        [self updateLoadingState];
    }
}

#pragma mark - Notification

- (void)notificationStillDidDownload:(NSNotification*)notification{
    NSURL *stillURL = [notification.userInfo objectForKey:kGiphyNetworkManagerRecievedObjectURLKey];
    
    if ([_stillURL isEqual:stillURL]) {
        _animateStillOnLoading = YES;
    }
}

#pragma mark - Private

- (void)updateLoadingState{
    if (_contentEmpty) {
        self.backgroundColor = self.placeholderColor;
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
