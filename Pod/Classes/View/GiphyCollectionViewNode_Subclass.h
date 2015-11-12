//
//  GiphyCollectionViewNode_Subclass.h
//  GiphyTest
//
//  Created by Russel on 19.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCollectionViewNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "GiphyNetworkManager.h"

@interface GiphyCollectionViewNode ()

#pragma mark - Initialize

- (void)configure;

#pragma mark - Giphy Collection View Node

@property(nonatomic, readwrite)BOOL contentEmpty;

@property(nonatomic, readwrite)BOOL animateStillOnLoading;

@property(nonatomic, weak)ASNetworkImageNode *placeholderImageNode;

@property(nonatomic, weak)ASDisplayNode *gifDisplayNode;

@property(nonatomic)NSURL *gifURL;

@property(nonatomic)NSURL *stillURL;

@property(nonatomic)id gifCancellationToken;

#pragma mark - Gif

/**
 *  Starts gif loading if correponding url provided and operation is not already in progress.
 */
- (void)startGifLoadingIfNeeded;

@end
