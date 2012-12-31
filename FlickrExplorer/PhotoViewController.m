//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoViewController

@synthesize imageView = _imageView;

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
