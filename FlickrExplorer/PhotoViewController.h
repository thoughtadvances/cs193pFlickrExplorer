//
//  PhotoViewController.h
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoViewController : UIViewController
<SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) UIImage *image; // image to be displayed
@end