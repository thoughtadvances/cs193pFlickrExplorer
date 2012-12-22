//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrExplorerAppDelegate.h" // NSUserDefaults key defines
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get URL, download, and convert to UIImage
    NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:
                       FlickrPhotoFormatLarge];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    UIImage *photoImage = [UIImage imageWithData:photoData];
    
    self.imageView.image = photoImage; // set the image on screen
    
    // set bounds
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width,
                                      self.imageView.image.size.height);
    self.scrollView.delegate = self;
    
    self.title = [self.photo objectForKey:@"title"]; // toolbar title = photo's
}

- (void)viewDidAppear:(BOOL)animated { // save photo to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recentPhotos = [defaults objectForKey:RECENT_PHOTOS_KEY];
    
    NSMutableArray *mutableRecentPhotos = [recentPhotos mutableCopy];
    
    if ([mutableRecentPhotos count] == 20) {
        [mutableRecentPhotos removeObjectAtIndex:0]; // remove oldest photo
    }
    
    if (![mutableRecentPhotos containsObject:self.photo]) {
        // Add only unique recents
        [mutableRecentPhotos insertObject:self.photo
                                  atIndex:[recentPhotos count]];
    }
    
    [defaults setObject:[mutableRecentPhotos copy] forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSUInteger)supportedInterfaceOrientations { // Support all orientations
    return UIInterfaceOrientationMaskAll;
}

@end
