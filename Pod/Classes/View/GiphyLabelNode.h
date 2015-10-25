//
//  GiphyLabelNode.h
//
//  Created by Russel on 08.06.15.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import "ASControlNode.h"

/**
 *  Subclass of ASControlNode designed to display
 *   single line label.
 */

@interface GiphyLabelNode : ASControlNode

/**
 *  Attributed string to display.
 */
@property(nonatomic, copy)NSAttributedString *attributedString;

@end
