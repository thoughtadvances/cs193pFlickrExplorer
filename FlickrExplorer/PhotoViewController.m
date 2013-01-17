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

- (void)setImage:(UIImage *)image {
    _image = image;
    [self updateImage];
}

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

// FIXME: Scroll view bounds are not being calculated correctly.  It should not
//  exceeed the current edge of the image
// FIXME: The image is not zooming up to the specified magnification on iPad
// FIXME: Why is the iPhone background black?
// FIXME: Making the zoom higher on iPad scrollView just makes the photo's
//  initial size smaller

// TODO: Should not be necessary because the struts and springs are now set
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        [self.scrollView setFrame:CGRectMake(0, self.toolbar.frame.size.height,
//                                             self.view.frame.size.width,
//                                             self.view.frame.size.height)];
//    } else {
//
//    }
//}

- (void)updateImage {
    self.imageView.image = self.image;
    // set bounds
    // FIXME: Is this a good value?  Should the contentSize be set to the size
    //  of the image?  The size of the image is fixed
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
    
    [self.imageView setNeedsDisplay]; // update screen on UIImage change
}

//- (void)viewDidLayoutSubviews {
//    [self updateImage];
//}

- (void)viewWillAppear:(BOOL)animated {
    [self updateImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSUInteger)supportedInterfaceOrientations { // Support all orientations
    return UIInterfaceOrientationMaskAll;
}

@end
