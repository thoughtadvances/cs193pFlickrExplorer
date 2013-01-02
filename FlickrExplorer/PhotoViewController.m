//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate,
UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIToolbar *toolbar; // for spplitViewController
@end

@implementation PhotoViewController

@synthesize imageView = _imageView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

// FIXME: Why doesn't this work?  Is it because it calls setNeedsDisplay before
//  the image has finished loading?
//- (void)setImage:(UIImage *)image {
//    NSLog(@"Image has been changed to %@", self.image);
//    [self.imageView setNeedsDisplay]; // update screen on photo change
//}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        // Update only if the old is different from the new
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) { // Remove old button if it exists
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if (splitViewBarButtonItem) { // Add new button if it exists
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self; // I tell the scrollView what to do
}

- (void)viewWillAppear:(BOOL)animated {
    // TODO: Set the photo size information so that as much as possible is shown
    self.imageView.image = self.image; // set the image on screen
    
    // set bounds
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width,
                                      self.imageView.image.size.height);
    
    // Calculate size differences between scrollView and the image
    double scale = 0.0;
    double widthDifference = fabs(self.scrollView.bounds.size.width -
                                  self.imageView.image.size.width);
    double heightDifference = fabs(self.scrollView.bounds.size.height -
                                   self.imageView.image.size.height);
    
    if (widthDifference > heightDifference) { // stretch height to fit
        scale = self.scrollView.bounds.size.height /
        self.imageView.image.size.height;
    } else { // stretch width to fit
        scale = self.scrollView.bounds.size.width /
        self.imageView.image.size.width;
    }
    
    // set initial scale to show as much of image as possible without any
    //  whitespace
    self.scrollView.zoomScale = scale;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSUInteger)supportedInterfaceOrientations { // Support all orientations
    return UIInterfaceOrientationMaskAll;
}

@end
