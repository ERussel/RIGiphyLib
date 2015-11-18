//
//  SNLabelNode.m
//
//  Created by Russel on 08.06.15.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import "GiphyLabelNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>

@implementation GiphyLabelNode

#pragma mark - Subclass

- (instancetype)init{
    self = [super init];
    if (self) {
        // apply default style
        self.opaque = NO;
    }
    return self;
}

+ (void)drawRect:(CGRect)bounds
  withParameters:(id<NSObject>)parameters
     isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock
   isRasterizing:(BOOL)isRasterizing{
    // draw attributed string if exists in parameters
    NSAttributedString *attributedString = [(NSDictionary*)parameters objectForKey:@"attributedString"];
    if (attributedString) {
        [attributedString drawWithRect:bounds options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine context:nil];
    }
}

- (NSObject*)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer{
    // pass attributed string to draw if provided
    if (_attributedString.length > 0) {
        return @{@"attributedString" : _attributedString};
    }else{
        return nil;
    }
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize{
    // calculated attributed string's rect to draw in one line
    CGRect boundingAttributedRect = [_attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, constrainedSize.height)
                                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                    context:nil];
    
    // apply constrains to result size
    CGSize calculatedSize = CGSizeMake(CGRectGetMaxX(boundingAttributedRect), CGRectGetMaxY(boundingAttributedRect));
    return CGSizeMake(MIN(calculatedSize.width, constrainedSize.width), MAX(calculatedSize.height, 0.0f));
}

- (void)setAttributedString:(NSAttributedString *)attributedString{
    // update attributed string
    _attributedString = [attributedString copy];
    
    // Tell the display node superclasses that the cached sizes are incorrect now
    [self setNeedsLayout];
    
    // redisplay
    [self setNeedsDisplay];
}

@end
