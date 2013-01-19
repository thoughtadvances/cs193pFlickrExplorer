//
//  FlickrPhotoSelectorTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrPhotoSelectorTableViewController.h"
#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "DetailViewController.h"
#import "FlickrPhotoViewController.h"

@interface FlickrPhotoSelectorTableViewController () <MapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPhotoSelectorTableViewController

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

- (void)setPlace:(NSDictionary *)place {
    _place = place;
    [self getPhotos];
}

- (void)getPhotos {
    [self.spinner startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.place maxResults:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinner.hidesWhenStopped = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.splitViewController) { // keep selection on iPad
        self.clearsSelectionOnViewWillAppear = NO;
    }
}

- (UIImage *)mapViewController:(MapViewController *)sender
            imageForAnnotation:(id<MKAnnotation>)annotation {
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    FlickrPhotoAnnotation *flickrAnnotation = (FlickrPhotoAnnotation *)annotation;
    
    // FIXME: How to do dispatch_async inside functions which do not have a void
    //  return value?
    
    //    dispatch_async(downloadQueue, ^{
    NSURL *url = [FlickrFetcher urlForPhoto:flickrAnnotation.photo format:
                  FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"dataWithContentsOfURL called");
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            return data ? [UIImage imageWithData:data] : nil;
    //        });
    //    });
    return data ? [UIImage imageWithData:data] : nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier
                             forIndexPath:indexPath];
    
    // most recent to least recent
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    id photoTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
    id photoDescription = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    // Set the cell text
    if (!photoDescription || ![photoDescription isKindOfClass:[NSString class]])
    {
        // ensure that the retrieved description meets all requirements
        photoDescription = @"";
    }
    
    if (!photoTitle || [photoTitle isEqualToString:@""] ||
        ![photoTitle isKindOfClass:[NSString class]]) {
        photoTitle = photoDescription; // Make title the description
        photoDescription = @""; // Title and description should not show same
    }
    
    if ([photoTitle isEqualToString:@""]) {
        // If also no description, then set standard title
        photoTitle = @"Unknown";
    }
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:photo format:
                           FlickrPhotoFormatSquare];
        NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *photoImage = [UIImage imageWithData:imageData];
            cell.imageView.image = photoImage;
        });
    });
    
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.photos objectAtIndex:indexPath.row];
    if (self.splitViewController) {
        UIViewController *detail = [[self.splitViewController.viewControllers
                                     lastObject] topViewController];
        if (![detail isKindOfClass:[PhotoViewController class]]) {
            [detail performSegueWithIdentifier:@"showTablePhoto" sender:self];
        } else [(FlickrPhotoViewController*)detail setPhoto:self.selectedPhoto];
    } else [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    }
}

@end
