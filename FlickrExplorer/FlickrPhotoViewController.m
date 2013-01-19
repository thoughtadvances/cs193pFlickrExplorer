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

@interface FlickrPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPhotoViewController

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo;
    NSLog(@"FlickPhotoView's image is %@", self.photo);
    [self updatePhoto];
}

- (void)storeFlickrPhotoData:(NSData*)data {
    dispatch_queue_t storageQueue = dispatch_queue_create("storage",
                                                          NULL);
    dispatch_async(storageQueue, ^{
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSURL* applicationDirectory = [IOSupport applicationDirectory];
        NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",
                              applicationDirectory, photoID];
        double size = [IOSupport sizeOfDirectory:[NSURL URLWithString:filePath]];
        if (size > 10) { // delete oldest accessed file
            NSURL *oldFile = [IOSupport
                              oldestFileInDirectory:applicationDirectory];
            [defaultManager removeItemAtURL:oldFile error:NULL];
        }
        [defaultManager createFileAtPath:filePath contents:data
                              attributes:NULL];
    });
}

- (void)updatePhoto { // Download photo and set it
    [self.spinner startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    
    dispatch_async(downloadQueue, ^{
        BOOL cached = NO;
        NSData *photoData;
        NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSArray *URLs = [IOSupport arrayOfFileURLsInDirectory:
                         [IOSupport applicationDirectory]];
        for (id URL in URLs) { // Is it locally stored?
            if ([URL isKindOfClass:[NSURL class]]) {
                NSString *filename;
                [URL getResourceValue:&filename forKey:NSURLNameKey error:NULL];
                if ([filename isEqualToString:photoID]) {
                    photoData = [NSData dataWithContentsOfURL:URL];
                    cached = YES;
                }
            }
        }
        if (!cached) { // If not, then download
            NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:
                               FlickrPhotoFormatLarge];
            photoData = [NSData dataWithContentsOfURL:photoURL];
            [self storeFlickrPhotoData:photoData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ // Display
            UIImage *photoImage = [UIImage imageWithData:photoData];
            self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
            self.image = photoImage;
            [self.spinner stopAnimating];
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
