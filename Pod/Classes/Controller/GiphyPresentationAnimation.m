//
//  GiphyPresentationAnimation.m
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyPresentationAnimation.h"
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>
#import "UIView+Giphy.h"
#import "UIImage+GiphyFilter.h"

@interface GiphyPresentationAnimation ()

#pragma mark - Giphy Presentation Animation

/**
 *  Image view to display blur background image.
 */
@property(nonatomic, weak)UIImageView *animationBackgroundView;

#pragma mark - Private

/**
 *  Calculates modal controller's view rect to fix orientation issue on iOS 7.
 *  @param transitionContext Context to extract transition parameters from.
 *  @return Final CGRect to apply to modal controller.
 */
- (CGRect)rectForPresentedState:(id<UIViewControllerContextTransitioning>)transitionContext;

@end

@implementation GiphyPresentationAnimation

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // The view controller's view that is presenting the modal view
    UIView *containerView = [transitionContext containerView];
    
    // extract controller animation starts from
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // extract controller animation completes in
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // clear controller's background to make blur background visible
    toViewController.view.backgroundColor = [UIColor clearColor];
    
    if (_animationType == GiphyPresentationAnimationTypeAppearance) {
        // generate blur background image
        UIImage *backgroundImage = [[fromViewController.view giphy_screenshotWithQuality:0.2f] giphy_blurImageWithRadius:0.3f tintColor:_backgroundTintColor];
        
        // create image view to display background image
        UIImageView *animationBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [containerView addSubview:animationBackgroundView];
        _animationBackgroundView = animationBackgroundView;
        
        // prepare for fade animation
        toViewController.view.alpha = 0.0f;
        _animationBackgroundView.alpha = 0.0f;
        
        // iOS 7 bug fix
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
            // setup final frame for modal view controller
            CGRect finalFrame = [self rectForPresentedState:transitionContext];
            toViewController.view.frame = finalFrame;
            
            // setup background position and rotation based on interface orientation
            _animationBackgroundView.center = CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame));
            switch (fromViewController.interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    _animationBackgroundView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    _animationBackgroundView.transform = CGAffineTransformMakeRotation(M_PI_2);
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    _animationBackgroundView.transform = CGAffineTransformMakeRotation(M_PI);
                    break;
                default:
                    break;
            }
        }
        
        [containerView addSubview:toViewController.view];
        
        // start fade appearance transition animation
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1.0f;
            _animationBackgroundView.alpha = 1.0f;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
        
    }else if (_animationType == GiphyPresentationAnimationTypeDismiss){
        // start fade dismiss animation
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.alpha = 0.0f;
            _animationBackgroundView.alpha = 0.0f;
            
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.35f;
}

#pragma mark - Private

- (CGRect)rectForPresentedState:(id<UIViewControllerContextTransitioning>)transitionContext{
    // return container's view bounds as display rect
    UIView *containerView = [transitionContext containerView];
    return CGRectMake(0, 0, containerView.bounds.size.width, containerView.bounds.size.height);
}

@end