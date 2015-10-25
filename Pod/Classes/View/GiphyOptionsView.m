//
//  GiphyOptionsView.m
//
//  Created by Russel on 03.09.15.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import "GiphyOptionsView.h"

@interface GiphyOptionsView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak)UIImageView *dimmedView;

@end

@implementation GiphyOptionsView

static NSString * const kOptionsCellIdentifier = @"OptionsCellIdentifier";

#pragma mark - Initialize

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame options:(NSArray *)options{
    if (self = [super initWithFrame:frame]) {
        _options = [options copy];
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure{
    // setup default values
    _anchorPoint = CGPointMake(0.5f, 0.0f);
    _preferredRowHeight = 44.0f;
    _rowBackgroundColor = [UIColor whiteColor];
    
    // setup default style
    self.backgroundColor = [UIColor clearColor];
    
    // configure dimmed view
    UIImageView *dimmedView = [[UIImageView alloc] initWithFrame:self.bounds];
    dimmedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dimmedView.userInteractionEnabled = YES;
    dimmedView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    [self addSubview:dimmedView];
    _dimmedView = dimmedView;
    
    UITapGestureRecognizer *dimmedTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(actionTapOnDimmedView:)];
    [dimmedView addGestureRecognizer:dimmedTapGestureRecognizer];
    
    // configure table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self addSubview:tableView];
    _tableView = tableView;
}

#pragma mark - Options View

- (void)setOptions:(NSArray *)options{
    if (![_options isEqualToArray:options]) {
        _options = [options copy];

        [self invalidateIntrinsicContentSize];
        
        [_tableView reloadData];
    }
}

- (void)setPreferredRowHeight:(CGFloat)preferredRowHeight{
    if (_preferredRowHeight != preferredRowHeight) {
        _preferredRowHeight = preferredRowHeight;
        
        [self invalidateIntrinsicContentSize];
        
        [_tableView reloadData];
    }
}

- (void)setDefaultTextAttributes:(NSDictionary *)defaultTextAttributes{
    if ([_defaultTextAttributes isEqual:defaultTextAttributes]) {
        _defaultTextAttributes = [defaultTextAttributes copy];
        
        [_tableView reloadData];
    }
}

- (void)setRowIcon:(UIImage *)rowIcon{
    if (![_rowIcon isEqual:rowIcon]) {
        _rowIcon = rowIcon;
        
        [_tableView reloadData];
    }
}

- (void)setRowBackgroundColor:(UIColor *)rowBackgroundColor{
    if (![_rowBackgroundColor isEqual:rowBackgroundColor]) {
        _rowBackgroundColor = rowBackgroundColor;
        
        [_tableView reloadData];
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint{
    if (!CGPointEqualToPoint(anchorPoint, _anchorPoint)) {
        CGPoint previousAnchorPoint = _anchorPoint;
        _anchorPoint = anchorPoint;
        
        if (self.visible) {
            // calculate position
            CGPoint position = CGPointMake(self.frame.origin.x + self.frame.size.width*previousAnchorPoint.x, self.frame.origin.y + self.frame.size.height*previousAnchorPoint.y);
            
            // update frame based on current anchor point
            self.frame = CGRectMake(position.x - self.frame.size.width*_anchorPoint.x, position.y - self.frame.size.height*_anchorPoint.y, self.frame.size.width, self.frame.size.height);
        }
    }
}

- (void)setDimmedColor:(UIColor *)dimmedColor{
    if ([_dimmedColor isEqual:dimmedColor]) {
        _dimmedColor = dimmedColor;
        
        _dimmedView.backgroundColor = _dimmedColor;
    }
}

#pragma mark - Subclass

- (CGSize)intrinsicContentSize{
    CGSize defaultSize = [super intrinsicContentSize];
    
    return CGSizeMake(defaultSize.width, _preferredRowHeight*[_options count]);
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_options count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *optionCell = [tableView dequeueReusableCellWithIdentifier:kOptionsCellIdentifier];
    if (!optionCell) {
        optionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOptionsCellIdentifier];
        
        // setup style
        if ([optionCell respondsToSelector:@selector(setLayoutMargins:)]) {
            [optionCell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([optionCell respondsToSelector:@selector(setSeparatorInset:)]) {
            [optionCell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    // setup cell style
    [optionCell setBackgroundColor:_rowBackgroundColor];
    
    // setup title
    id title = [_options objectAtIndex:indexPath.row];
    
    if ([title isKindOfClass:[NSString class]]) {
        // string title
        optionCell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:_defaultTextAttributes];
    }else if([title isKindOfClass:[NSAttributedString class]]){
        // attributed string title
        optionCell.textLabel.attributedText = title;
    }else{
        // not supported title
        optionCell.textLabel.attributedText = nil;
    }
    
    // setup cell icon
    [optionCell.imageView setImage:_rowIcon];
    
    return optionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _preferredRowHeight;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_delegate optionsView:self didSelectOptionAtIndex:indexPath.row];
}

#pragma mark - Options View

- (void)showOnView:(UIView*)view position:(CGPoint)position animated:(BOOL)animated{
    if (!_visible) {
        _visible = YES;
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        self.frame = CGRectMake(position.x - self.frame.size.width*_anchorPoint.x, position.y - self.frame.size.height*_anchorPoint.y, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.0f;
        [view addSubview:self];
        
        [UIView animateWithDuration:0.35f
                         animations:^{
                             self.alpha = 1.0f;
                         }];
        
        [CATransaction commit];
    }
}

- (void)hideAnimated:(BOOL)animated{
    if (_visible) {
        _visible = NO;
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        [UIView animateWithDuration:0.35f
                         animations:^{
                             self.alpha = 0.0f;
                         } completion:^(BOOL finished){
                             if (!_visible) {
                                 [self removeFromSuperview];
                             }
                         }];
        
        [CATransaction commit];
    }
}

#pragma mark - Action

- (void)actionTapOnDimmedView:(UITapGestureRecognizer*)tapGestureRecognizer{
    if ([tapGestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(optionsWillHideView:)]) {
            [self.delegate optionsWillHideView:self];
        }
        
        [self hideAnimated:YES];
    }
}

@end
