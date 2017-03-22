//
//  GiphyViewController.m
//  RIGiphyLib
//
//  Created by Russel on 10/25/2015.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import "GiphyViewController.h"
#import <RIGiphyLib/GiphyNavigationController.h>
#import <RIGiphyLib/GiphyNetworkManager.h>
#import "TMCache+GiphyCacheProtocol.h"

@interface GiphyViewController ()<GiphyNavigationControllerDelegate>

@property(nonatomic, weak)IBOutlet UISwitch *gifPreloadSwitch;

@property(nonatomic, weak)IBOutlet UISwitch *placeholderSwitch;

@end

@implementation GiphyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Giphy Navigation Controller Delegate

- (void)giphyNavigationController:(GiphyNavigationController *)giphyNavigationController didSelectGIFObject:(GiphyGIFObject *)gifObject{
    NSLog(@"Did select GIF %@",gifObject.originalGifURL);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[[TMCache sharedCache] memoryCache] removeAllObjects];
}

- (void)giphyNavigationControllerDidCancel:(GiphyNavigationController *)giphyNavigationController{
    NSLog(@"Did cancel GIF picking");
    
    [[[TMCache sharedCache] memoryCache] removeAllObjects];
}

#pragma mark - Action

- (IBAction)actionOpenGIF:(id)sender{
    if (![GiphyNetworkManager isInitialized]) {
        GiphyNetworkManagerConfiguration *config = [[GiphyNetworkManagerConfiguration alloc] init];
        config.parseApplicationId = @"vx7UlnLE2NzZCO95UjwdDaRKunB72grihAZeUw1W";
        config.parseClientKey = @"O7JmKpUa62V2w8WP41josZb4k56k3281rT8jWBZX";
        config.parseServer = @"https://swist.herokuapp.com/parse";
        config.categoryPath = @"classes/GIFCategory";
        
        [GiphyNetworkManager initializeWithConfiguration:config];
    }
    
    GiphyNavigationController *giphyController = [[GiphyNavigationController alloc] initWithCache:[TMCache sharedCache]
                                                                                                     dataManager:nil
                                                                                          networkActivityManager:nil];
    giphyController.delegate = self;
    giphyController.ignoresGIFPreloadForCell = [_gifPreloadSwitch isOn];
    giphyController.usesOriginalStillAsPlaceholder = [_placeholderSwitch isOn];
    giphyController.previewBlurColor = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
    giphyController.cellPlaceholderColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    
    [self presentViewController:giphyController
                       animated:YES
                     completion:nil];
}

@end
