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

@property(nonatomic, weak)FLAnimatedImageView *gifView;
@property(nonatomic)id gifLoadingCancellationToken;

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
    self.view.backgroundColor = [UIColor clearColor];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(self.view.frame.size.width - 50.0f, 20.0f, 50.0f, 50.0f)];
    [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [closeButton setImage:[GiphyBundle imageNamed:@"close_preview_icon.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(actionCancel)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
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
    
    FLAnimatedImageView *gifView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(closeButton.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(closeButton.frame) - CGRectGetHeight(doneButton.frame) - 8.0f)];
    gifView.userInteractionEnabled = YES;
    [gifView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [gifView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:gifView];
    _gifView = gifView;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(actionCancel)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [gifView addGestureRecognizer:swipeGestureRecognizer];
    
    [self updateGifData];
}

#pragma mark - Giphy Preview View Controller

- (void)setGifObject:(GiphyGIFObject *)gifObject{
    if (![_gifObject isEqualToGIF:gifObject]) {
        _gifObject = gifObject;
        
        if (self.isViewLoaded) {
            [self updateGifData];
        }
    }
}

#pragma mark - Action

- (void)actionCancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionDone{
    NSDictionary *userInfo = _gifObject ? @{kGiphyNotificationGIFObjectKey : _gifObject} : nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNavigationControllerDidSelectGIFNotification
                                                            object:self
                                                          userInfo:userInfo];
    }];
}

#pragma mark - Data

- (void)updateGifData{
    [self cancelGifDataLoading];
    
    if (_gifObject) {
        
        __weak MBProgressHUD *weakProgressHud = [MBProgressHUD HUDForView:self.view];
        if (!weakProgressHud) {
            weakProgressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [weakProgressHud setMode:MBProgressHUDModeAnnularDeterminate];
            weakProgressHud.userInteractionEnabled = NO;
        }else{
            [weakProgressHud setProgress:0.0f];
        }
        
        __weak __typeof(self) weakSelf = self;
        
        self.gifLoadingCancellationToken = [[GiphyNetworkManager sharedManager] getGIFByURL:_gifObject.originalGifURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            successBlock:^(FLAnimatedImage *animatedImage){
                                                if (weakSelf.gifLoadingCancellationToken) {
                                                    weakSelf.gifLoadingCancellationToken = nil;
                                                    
                                                    [weakSelf.gifView setAnimatedImage:animatedImage];
                                                    
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
