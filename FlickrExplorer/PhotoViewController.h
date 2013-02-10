//
//  PhotoViewController.h
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
@property (nonatomic, strong) UIImage *image; // image to be displayed
// spinning gear to show while downloading the image.  Commands for
//  operating the spinner should be set in the subclass
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@end