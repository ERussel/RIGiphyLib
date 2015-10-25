//
//  GiphyViewController.m
//  RIGiphyLib
//
//  Created by Russel on 10/25/2015.
//  Copyright (c) 2015 Russel. All rights reserved.
//

#import "GiphyViewController.h"
#import <RIGiphyLib/GiphyNavigationController.h>

@interface GiphyViewController ()

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

#pragma mark - Action

- (IBAction)actionOpenGIF:(id)sender{
    GiphyNavigationController *giphyController = [[GiphyNavigationController alloc] initWithImageCache:nil
                                                                                           dataManager:nil
                                                                                networkActivityManager:nil];
    [self presentViewController:giphyController
                       animated:YES
                     completion:nil];
}

@end
