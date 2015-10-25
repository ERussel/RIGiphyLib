//
//  GiphyPresentationAnimation.h
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    GiphyPresentationAnimationTypeAppearance,
    GiphyPresentationAnimationTypeDismiss
}GiphyPresentationAnimationType;

@interface GiphyPresentationAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property(nonatomic)GiphyPresentationAnimationType animationType;

@property(nonatomic)UIColor *backgroundTintColor;

@end
