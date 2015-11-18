//
//  GiphyCollectionViewNode.h
//  GiphyTest
//
//  Created by Russel on 16.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface GiphyCollectionViewNode : ASCellNode

- (instancetype)initWithStillURL:(NSURL*)stillURL
                          gifURL:(NSURL*)gifURL
                   preferredSize:(CGSize)preferredSize;

@property(nonatomic)CGSize preferredSize;

@property(nonatomic)UIColor *placeholderColor;

@end
