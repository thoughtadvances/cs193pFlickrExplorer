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
#import "SegmentedViewController.h"

@interface FlickrPhotoSelectorTableViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPhotoSelectorTableViewController

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self updateMapAnnotations];
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
    [self.spinner startAnimating];
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.place maxResults:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.tableView reloadData];
        });
    });
}

- (NSArray *)mapAnnotations {
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:
                                   [self.photos count]];
    for (NSDictionary *photo in self.photos)
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    return annotations;
}


# pragma mark Lifecycle methods

// FIXME: Almost complete duplicate of the same method in TopPlacesTable
//  ViewController
- (void)updateMapAnnotations {
    if (self.splitViewController) {
        id detail = [self.splitViewController.viewControllers lastObject];
        detail = [detail getViewControllerWithID:@"MapViewController"];
        if (self.photos) [detail setAnnotations:[self mapAnnotations]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.splitViewController) [self.spinner startAnimating];
    [self updateMapAnnotations];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Photo";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier
                             forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    id photoTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
    id photoDescription = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    // Set the cell text
    if (!photoDescription || ![photoDescription isKindOfClass:[NSString class]])
        photoDescription = @"";
    
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
    cell.imageView.image = nil;
    dispatch_async(downloadQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:photo format:
                           FlickrPhotoFormatSquare];
        NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
        UIImage *photoImage = [UIImage imageWithData:imageData];
        if (photoImage)
            dispatch_async(dispatch_get_main_queue(), ^{
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
        id detail = [self.splitViewController.viewControllers lastObject];
        [detail changeToViewControllerNamed:@"PhotoViewController"];
        detail = [detail getViewControllerWithID:@"PhotoViewController"];
        [(id)detail setPhoto:self.selectedPhoto];
    } else [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

#pragma mark - Other view controllers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    }
    else if ([segue.identifier isEqualToString:@"showMap"]) {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}
@end
