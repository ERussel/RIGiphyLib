//
//  GiphyOptionsView.h
//
//  Created by Russel on 03.09.15.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiphyOptionsView;

@protocol GiphyOptionsViewDelegate <NSObject>

- (void)optionsView:(GiphyOptionsView*)optionsView didSelectOptionAtIndex:(NSInteger)selectedIndex;

@optional

- (void)optionsWillHideView:(GiphyOptionsView *)optionsView;

@end

@interface GiphyOptionsView : UIView

- (instancetype)initWithFrame:(CGRect)frame options:(NSArray*)options;

@property(nonatomic, weak)id<GiphyOptionsViewDelegate> delegate;

@property(nonatomic, readonly)UITableView *tableView;

@property(nonatomic, copy)NSArray *options;
@property(nonatomic, readwrite)CGPoint anchorPoint;
@property(nonatomic, readwrite)CGFloat preferredRowHeight;
@property(nonatomic, copy)NSDictionary *defaultTextAttributes;
@property(nonatomic)UIImage *rowIcon;
@property(nonatomic)UIColor *rowBackgroundColor;
@property(nonatomic)UIColor *dimmedColor;
@property(nonatomic, readonly)BOOL visible;

- (void)showOnView:(UIView*)view position:(CGPoint)position animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
