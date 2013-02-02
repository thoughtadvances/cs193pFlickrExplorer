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
#import "IOSupport.h"
#import "FlickrPhotoSelectorTableViewController.h"
#import "ViewControllerSupport.h"

@interface FlickrPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPhotoViewController

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo;
    [self updatePhoto];
}

- (void)storeFlickrPhotoData:(NSData*)data {
    dispatch_queue_t storageQueue = dispatch_queue_create("storage",
                                                          nil);
    dispatch_async(storageQueue, ^{
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSURL* applicationDirectory = [IOSupport applicationDirectory];
        NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSURL* filePath = [applicationDirectory URLByAppendingPathComponent:
                           photoID];
        NSLog(@"filePath = %@", [filePath path]);
        double size = [IOSupport sizeOfDirectory:applicationDirectory];
        NSLog(@"size of the image cache is %f", size);
        if (size > 10) { // delete oldest accessed file
            NSURL *oldFile = [IOSupport
                              oldestFileInDirectory:applicationDirectory];
            [defaultManager removeItemAtURL:oldFile error:nil];
        }
        NSLog(@"filePath = %@", [filePath path]);
        [defaultManager createFileAtPath:[filePath path] contents:data
                              attributes:nil];
    });
}

- (NSData*)getCachedPhotoWithID:(NSString*)photoID {
    NSArray *URLs = [IOSupport arrayOfFileURLsInDirectory:
                     [IOSupport applicationDirectory]];
    for (NSURL* URL in URLs) { // Is it locally stored?
        NSString *filename;
        [URL getResourceValue:&filename forKey:NSURLNameKey error:NULL];
        if ([filename isEqualToString:photoID]) {
            return [NSData dataWithContentsOfURL:URL];
        }
    }
    return nil;
}

- (void)updatePhoto { // Download photo and set it
    [self.spinner startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           nil);
    
    dispatch_async(downloadQueue, ^{
        NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSData *photoData = [self getCachedPhotoWithID:photoID];
        
        if (!photoData) { // if note cached, then download
            NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:
                               FlickrPhotoFormatLarge];
            photoData = [NSData dataWithContentsOfURL:photoURL];
            if (photoURL && photoData) [self storeFlickrPhotoData:photoData];
        }
        
        UIImage *photoImage = [UIImage imageWithData:photoData];
        dispatch_async(dispatch_get_main_queue(), ^{ // Display
            [self.spinner stopAnimating];
            id master =
            [self.splitViewController.viewControllers objectAtIndex:0];
            master = [ViewControllerSupport getNonNavigationControllerFor:master];
            if ([master respondsToSelector:@selector(selectedPhoto)] &&
                [[master selectedPhoto] isEqualToDictionary:self.photo]) {
                // FIXME: How to clean up this duplication?
                self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
                self.image = photoImage;
            }
            if (!self.splitViewController) { // iPhone update
                self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
                self.image = photoImage;
            }
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinner.hidesWhenStopped = YES;
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
