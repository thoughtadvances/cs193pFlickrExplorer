//
//  FlickrPhotoViewController.m
//  FlickrExplorer
//
//  Created by admin on 22/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h" // download photo
#import "FlickrExplorerAppDelegate.h" // NSUserDefaults defines

@interface FlickrPhotoViewController ()

@end

@implementation FlickrPhotoViewController

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo; // set new photo
    [self updatePhoto]; // get new image and set it in the UIImageView
}

- (void)updatePhoto {
    // Get URL, download, and convert to UIImage
    NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:
                       FlickrPhotoFormatLarge];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    UIImage *photoImage = [UIImage imageWithData:photoData];
    
    // toolbar title = photo's title
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    self.image = photoImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: This should not be necessary because the setter will also do it
    //  on iPhone
//    if (self.navigationController) { // Show image on iPhone
//        [self updatePhoto];
//    }
    
}

- (void)viewDidAppear:(BOOL)animated { // save photo to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // make sure I'm up-to-date
    NSArray *recentPhotos = [defaults objectForKey:RECENT_PHOTOS_KEY];
    
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
    [defaults setObject:[mutableRecentPhotos copy] forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

@end
