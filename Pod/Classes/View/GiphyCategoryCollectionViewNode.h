//
//  GiphyCategoryCollectionViewNode.h
//  GiphyTest
//
//  Created by Russel on 16.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCollectionViewNode.h"

@interface GiphyCategoryCollectionViewNode : GiphyCollectionViewNode

- (instancetype)initWithStillURL:(NSURL *)stillURL
                          gifURL:(NSURL *)gifURL
                   preferredSize:(CGSize)preferredSize
                           title:(NSAttributedString*)titleAttributedString;

@property(nonatomic)UIColor *dimmedTitleColor;

@end
