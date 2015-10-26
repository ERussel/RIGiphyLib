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

@property(nonatomic, weak)UIImageView *animationBackgroundView;

@end

@implementation GiphyPresentationAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    //The view controller's view that is presenting the modal view
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (_animationType == GiphyPresentationAnimationTypeAppearance) {
        UIImage *backgroundImage = [[fromViewController.view giphy_screenshotWithQuality:0.2f] giphy_blurImageWithRadius:0.3f tintColor:_backgroundTintColor];
        
        UIImageView *animationBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [containerView addSubview:animationBackgroundView];
        _animationBackgroundView = animationBackgroundView;
        
        toViewController.view.alpha = 0.0f;
        _animationBackgroundView.alpha = 0.0f;
        
        // iOS 7 bug fix
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
            // setup final frame for modal view controller
            CGRect finalFrame = [self rectForPresentedStateEnd:transitionContext];
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
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1.0f;
            _animationBackgroundView.alpha = 1.0f;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
        
    }else if (_animationType == GiphyPresentationAnimationTypeDismiss){
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

- (CGRect)rectForPresentedStateStart:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    switch (fromViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(0, containerView.bounds.size.height,
                              containerView.bounds.size.width, containerView.bounds.size.height);
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(0, - containerView.bounds.size.height,
                              containerView.bounds.size.width, containerView.bounds.size.height);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(- containerView.bounds.size.width, 0,
                              containerView.bounds.size.width, containerView.bounds.size.height);
        case UIInterfaceOrientationPortrait:
            return CGRectMake(containerView.bounds.size.width, 0,
                              containerView.bounds.size.width, containerView.bounds.size.height);
        default:
            return CGRectZero;
    }
    
}

- (CGRect)rectForPresentedStateEnd:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    
    switch (toViewController.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            return CGRectOffset([self rectForPresentedStateStart:transitionContext], 0, - containerView.bounds.size.height);
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectOffset([self rectForPresentedStateStart:transitionContext], 0, containerView.bounds.size.height);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectOffset([self rectForPresentedStateStart:transitionContext], containerView.bounds.size.width, 0);
        case UIInterfaceOrientationPortrait:
            return CGRectOffset([self rectForPresentedStateStart:transitionContext], - containerView.bounds.size.width, 0);
        default:
            return CGRectZero;
    }
}

@end