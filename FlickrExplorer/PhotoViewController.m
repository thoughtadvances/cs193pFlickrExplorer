//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoViewController.h"
#import "IOSupport.h"

@interface PhotoViewController () <UIScrollViewDelegate,
UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoViewController
- (void)setImage:(UIImage *)image {
    _image = image;
    [self updateImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

// FIXME: Scroll view bounds are not being calculated correctly.  It should not
//  exceeed the current edge of the image
// FIXME: The image is not zooming up to the specified magnification on iPad
// FIXME: Why is the iPhone background black?
// FIXME: Making the zoom higher on iPad scrollView just makes the photo's
//  initial size smaller

- (void)updateImage {
    self.imageView.image = self.image;
    // set bounds
    // FIXME: Is this a good value?  Should the contentSize be set to the size
    //  of the image?  The size of the image is fixed
    CGFloat width = self.imageView.image.size.width *
    self.scrollView.maximumZoomScale;
    CGFloat height =  self.imageView.image.size.height *
    self.scrollView.maximumZoomScale;
    self.scrollView.contentSize = CGSizeMake(width, height);
//    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width,
                                      self.imageView.image.size.height);
    
    // Calculate size differences between scrollView and the image
//    double scale = 0.0;
//    double widthDifference = fabs(self.scrollView.bounds.size.width -
//                                  self.imageView.image.size.width);
//    double heightDifference = fabs(self.scrollView.bounds.size.height -
//                                   self.imageView.image.size.height);
//    
//    if (widthDifference > heightDifference) { // stretch height to fit
//        scale = self.scrollView.bounds.size.height /
//        self.imageView.image.size.height;
//    } else { // stretch width to fit
//        scale = self.scrollView.bounds.size.width /
//        self.imageView.image.size.width;
//    }
    
    // set initial scale to show as much of image as possible without any
    //  whitespace
//    self.scrollView.zoomScale = scale;
    
    [self.imageView setNeedsDisplay]; // update screen on UIImage change
}

- (void)viewWillLayoutSubviews { // Make sure the spinner is centered in
    //  the imageView
    [super viewWillLayoutSubviews];
    CGFloat centerY = self.scrollView.frame.size.height / 2;
    CGFloat centerX = self.scrollView.frame.size.width / 2;
    self.spinner.frame = CGRectMake(0, 0, centerX, centerY);
    self.spinner.frame = CGRectMake(centerX, centerY, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSUInteger)supportedInterfaceOrientations { // Support all orientations
    return UIInterfaceOrientationMaskAll;
}

@end
