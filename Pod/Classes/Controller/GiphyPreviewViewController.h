//
//  GiphyPreviewViewController.h
//  GiphyTest
//
//  Created by Russel on 22.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiphyGIFObject.h"

@interface GiphyPreviewViewController : UIViewController

@property(nonatomic)GiphyGIFObject *gifObject;

- (instancetype)initWithGifObject:(GiphyGIFObject*)gifObject;

@end