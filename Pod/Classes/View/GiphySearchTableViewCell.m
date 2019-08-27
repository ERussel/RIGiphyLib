//
//  GiphySearchTableViewCell.m
//  GiphyTest
//
//  Created by Russel on 16.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphySearchTableViewCell.h"

@implementation GiphySearchTableViewCell

#pragma mark - Initialize

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
    [self configure];
}

- (void)configure{
    self.separatorInset = UIEdgeInsetsZero;
    
    if([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.imageView.image = [UIImage imageNamed:@"search_icon.png"];
}


@end
