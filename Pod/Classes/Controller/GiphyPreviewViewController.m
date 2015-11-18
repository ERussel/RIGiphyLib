//
//  GiphyPreviewViewController.m
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyPreviewViewController.h"
#import "GiphyNavigationController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GiphyNetworkManager.h"
#import "GiphyBundle.h"

@interface GiphyPreviewViewController ()

#pragma mark - Giphy Preview Controller

/**
 *  Animated image view to display preview GIF data
 */
@property(nonatomic, weak)FLAnimatedImageView *gifView;

/**
 *  Token to cancel gif downloading operation.
 *  \sa cancelGifDataLoading
 */
@property(nonatomic)id gifLoadingCancellationToken;

#pragma mark - Action

/**
 *  Invoked when user pressed cancel button or performed swiped down.
 *  Method dismisses preview controller and notifies delegate that selection was cancelled.
 */
- (void)actionCancel;

/**
 *  Invoked when user pressed selection button. Method notifies delegate about selection
 *  and post <b>GiphyNavigationControllerDidSelectGIFNotification</b> notification with GIF object.
 */
- (void)actionDone;

#pragma mark - Data

/**
 *  Starts GIF downloading. If there is not completed preview GIF downloading operation it would be cancelled.
 */
- (void)updateGifData;

/**
 *  Cancels current GIF downloading operation.
 */
- (void)cancelGifDataLoading;

@end

@implementation GiphyPreviewViewController

#pragma mark - Memory

- (void)dealloc{
    [self cancelGifDataLoading];
}

#pragma mark - Initialize

- (instancetype)initWithGifObject:(GiphyGIFObject *)gifObject{
    self = [super init];
    if (self) {
        _gifObject = gifObject;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // setup close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        [closeButton setFrame:CGRectMake(self.view.frame.size.width - 50.0f, 20.0f, 50.0f, 50.0f)];
    }else{
        [closeButton setFrame:CGRectMake(self.view.frame.size.width - 50.0f, 0.0f, 50.0f, 50.0f)];
    }
    
    [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [closeButton setImage:[GiphyBundle imageNamed:@"close_preview_icon.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(actionCancel)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // setup done button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(0.0f, self.view.bounds.size.height - 50.0f, self.view.bounds.size.width, 50.0f)];
    [doneButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [doneButton addTarget:self
                   action:@selector(actionDone)
         forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:[[GiphyBundle localizedString:@"LGiphyPreviewSendTitle"] uppercaseString] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor colorWithRed:54.0f/255.0f
                                                   green:98.0f/255.0f
                                                    blue:160.0f/255.0f
                                                   alpha:1.0f]];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:doneButton];
    
    // setup animated gif image view
    FLAnimatedImageView *gifView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(closeButton.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(closeButton.frame) - CGRectGetHeight(doneButton.frame) - 8.0f)];
    gifView.userInteractionEnabled = YES;
    [gifView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [gifView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:gifView];
    _gifView = gifView;
    
    // add swipe down gesture recognizer to cancel gif preview
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(actionCancel)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [gifView addGestureRecognizer:swipeGestureRecognizer];
    
    // start loading gif data
    [self updateGifData];
}

#pragma mark - Giphy Preview View Controller

- (void)setGifObject:(GiphyGIFObject *)gifObject{
    // reload gif preview on object changes
    if (![_gifObject isEqualToGIF:gifObject]) {
        _gifObject = gifObject;
        
        if (self.isViewLoaded) {
            [self updateGifData];
        }
    }
}

#pragma mark - Action

- (void)actionCancel{
    // notify delegate that user cancelled selection
    if ([self.delegate respondsToSelector:@selector(giphyPreviewControllerDidCancel:)]) {
        [self.delegate giphyPreviewControllerDidCancel:self];
    }
    
    // close preview controller
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionDone{
    // notify delegate that user wants to complete GIF selection
    if ([self.delegate respondsToSelector:@selector(giphyPreviewController:didSelectGIFObject:)]) {
        [self.delegate giphyPreviewController:self didSelectGIFObject:_gifObject];
    }
    
    // post notification that user wants to complete GIF selection
    NSDictionary *userInfo = _gifObject ? @{kGiphyNotificationGIFObjectKey : _gifObject} : nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNavigationControllerDidSelectGIFNotification
                                                            object:self
                                                          userInfo:userInfo];
    }];
}

#pragma mark - Data

- (void)updateGifData{
    // cancel downloading current GIF data
    [self cancelGifDataLoading];
    
    if (_gifObject) {
        
        // display downloading progress
        __weak MBProgressHUD *weakProgressHud = [MBProgressHUD HUDForView:self.view];
        if (!weakProgressHud) {
            weakProgressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [weakProgressHud setMode:MBProgressHUDModeAnnularDeterminate];
            weakProgressHud.userInteractionEnabled = NO;
        }else{
            [weakProgressHud setProgress:0.0f];
        }
        
        // start downloading new GIF data
        __weak __typeof(self) weakSelf = self;
        self.gifLoadingCancellationToken = [[GiphyNetworkManager sharedManager] getGIFByURL:_gifObject.originalGifURL
                                             cachePolicy:kGiphyRequestCachePolicyReturnCachedElseLoad
                                            successBlock:^(FLAnimatedImage *animatedImage){
                                                if (weakSelf.gifLoadingCancellationToken) {
                                                    weakSelf.gifLoadingCancellationToken = nil;
                                                    
                                                    // display loaded GIF
                                                    [weakSelf.gifView setAnimatedImage:animatedImage];
                                                    
                                                    // close progress view
                                                    [weakProgressHud hide:YES];
                                                }
                                            } progressBlock:^(CGFloat progress){
                                                [weakProgressHud setProgress:progress];
                                            } failureBlock:^(NSError *error){
                                                weakSelf.gifLoadingCancellationToken = nil;
                                                
                                                [weakProgressHud hide:YES];
                                            }];
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}

- (void)cancelGifDataLoading{
    if (_gifLoadingCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_gifLoadingCancellationToken];
        _gifLoadingCancellationToken = nil;
    }
}

@end
