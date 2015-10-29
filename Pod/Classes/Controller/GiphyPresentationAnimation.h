//
//  GiphyPresentationAnimation.h
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Type to specify animation for transition
 */
typedef enum {
    /**
     *  Appearance animation should be applied
     */
    GiphyPresentationAnimationTypeAppearance,
    
    /**
     *  Dismiss animation should be applied
     */
    GiphyPresentationAnimationTypeDismiss
}GiphyPresentationAnimationType;

/**
 *  Subclass of NSObject designed to provide custom animation to present/dismiss
 *  modal controller with blur background.
 */

@interface GiphyPresentationAnimation : NSObject<UIViewControllerAnimatedTransitioning>

/**
 *  Current animation type.
 *  @discussion This property must be set up before returning object from delegate method.
 *  \sa GiphyPresentationAnimationType.
 */
@property(nonatomic)GiphyPresentationAnimationType animationType;

/**
 *  Color to apply to blur background image to make it monochrome.
 *  By default nil.
 */
@property(nonatomic)UIColor *backgroundTintColor;

@end
