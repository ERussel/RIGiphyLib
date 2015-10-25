//
//  GiphyCategoryCollectionViewNode.m
//  GiphyTest
//
//  Created by Russel on 16.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyCategoryCollectionViewNode.h"
#import "GiphyCollectionViewNode_Subclass.h"
#import "GiphyLabelNode.h"

@interface GiphyCategoryCollectionViewNode ()

@property(nonatomic, weak)GiphyLabelNode *titleNode;
@property(nonatomic, weak)ASDisplayNode *dimmedNode;
@property(nonatomic)NSAttributedString *titleAttributedString;

@end

@implementation GiphyCategoryCollectionViewNode

#pragma mark - Initialize

- (instancetype)initWithStillURL:(NSURL *)stillURL
                          gifURL:(NSURL *)gifURL
                   preferredSize:(CGSize)preferredSize
                           title:(NSAttributedString*)titleAttributedString{
    self = [super initWithStillURL:stillURL
                            gifURL:gifURL
                     preferredSize:preferredSize];
    if (self) {
        [self configureDimmedNode];
        [self configureTitleNodeWithAttributedString:titleAttributedString];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configureDimmedNode];
        [self configureTitleNodeWithAttributedString:nil];
    }
    return self;
}

- (void)configureDimmedNode{
    ASDisplayNode *dimmedNode = [[ASDisplayNode alloc] init];
    dimmedNode.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    [self addSubnode:dimmedNode];
    _dimmedNode = dimmedNode;
}

- (void)configureTitleNodeWithAttributedString:(NSAttributedString*)title{
    GiphyLabelNode *titleNode = [[GiphyLabelNode alloc] init];
    [titleNode setAttributedString:title];
    [self addSubnode:titleNode];
    _titleNode = titleNode;
}

#pragma mark - Giphy Category Collection View Node

- (void)setDimmedTitleColor:(UIColor *)dimmedTitleColor{
    _titleNode.backgroundColor = dimmedTitleColor;
}

- (UIColor*)dimmedTitleColor{
    return _titleNode.backgroundColor;
}

#pragma mark - Subclass

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize{
    [_titleNode measure:CGSizeMake(MIN(constrainedSize.width, self.preferredSize.width), MIN(constrainedSize.height, self.preferredSize.height))];
    return [super calculateSizeThatFits:constrainedSize];
}

- (void)layout{
    [super layout];
    
    _dimmedNode.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, self.calculatedSize.height);
    _titleNode.frame = CGRectMake(roundf(self.calculatedSize.width/2.0f - _titleNode.calculatedSize.width/2.0f),
                                  roundf(self.calculatedSize.height/2.0f - _titleNode.calculatedSize.height/2.0f),
                                  _titleNode.calculatedSize.width,
                                  _titleNode.calculatedSize.height);
}

@end
