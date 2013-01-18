//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 22/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"
#import "FlickrExplorerAppDelegate.h"

@interface FlickrPhotoViewController ()

@end

@implementation FlickrPhotoViewController

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo;
    [self updatePhoto];
}

- (void)updatePhoto { // Download photo and set it
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:
                                        UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:
                           FlickrPhotoFormatLarge];
        NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *photoImage = [UIImage imageWithData:photoData];
            self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
            self.image = photoImage;
            self.navigationItem.rightBarButtonItem = nil;
        });
    });
}

- (void)viewDidAppear:(BOOL)animated { // save photo to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // make sure I'm up-to-date
    NSArray *recentPhotos = [defaults objectForKey:RECENT_PHOTOS];
    
    NSMutableArray *mutableRecentPhotos = [recentPhotos mutableCopy];
    
    if ([mutableRecentPhotos count] == 20) {
        [mutableRecentPhotos removeObjectAtIndex:19]; // remove oldest photo
    }
    
    if (![mutableRecentPhotos containsObject:self.photo]) { // must be unique
        if (self.photo) { // photo must exist
            // Add the photo at the end of the array
            [mutableRecentPhotos insertObject:self.photo atIndex:0];
        }
    }
    
    // Put back into preferences and write to disk
    [defaults setObject:[mutableRecentPhotos copy] forKey:RECENT_PHOTOS];
    [defaults synchronize];
}

@end
