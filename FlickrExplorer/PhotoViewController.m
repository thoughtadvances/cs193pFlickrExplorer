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
    if (image) [self updateImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)updateImage {
    self.imageView.image = self.image;
    [self setSizes];
    [self setScrollViewZoom];
    [self.imageView setNeedsDisplay]; // update screen on UIImage change
}

- (void)setSizes {
    self.imageView.frame = CGRectMake(0, 0,
                                      self.imageView.image.size.width,
                                      self.imageView.image.size.height);
    self.scrollView.contentSize = CGSizeMake(self.imageView.image.size.width,
                                             self.imageView.image.size.height);
}

- (void)setScrollViewZoom { // show as much of image with no whitespace
    
    // Calculate size differences between scrollView and the image
    double scale;
    double widthDifference = fabs(self.scrollView.bounds.size.width -
                                  self.imageView.image.size.width);
    double heightDifference = fabs(self.scrollView.bounds.size.height -
                                   self.imageView.image.size.height);
    
    if (widthDifference > heightDifference)    // stretch height to fit
        scale = self.scrollView.bounds.size.height /
        self.imageView.image.size.height;
    else    // stretch width to fit
        scale = self.scrollView.bounds.size.width /
        self.imageView.image.size.width;
    [self.scrollView setZoomScale:scale animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"self.scrollView.size = %f, %f", self.scrollView.contentSize.height, self.scrollView.contentSize.width);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Center the spinner on the imageView
    CGFloat centerY = self.scrollView.frame.size.height / 2;
    CGFloat centerX = self.scrollView.frame.size.width / 2;
    self.spinner.frame = CGRectMake(0, 0, centerX, centerY);
    self.spinner.frame = CGRectMake(centerX, centerY, 0, 0);
    // Set here for rotations
    //    if (self.imageView.image) [self setScrollViewBounds];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    if (self.imageView.image) [self setScrollViewBounds];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSUInteger)supportedInterfaceOrientations { // Support all orientations
    return UIInterfaceOrientationMaskAll;
}

@end
