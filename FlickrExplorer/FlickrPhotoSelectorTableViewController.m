//
//  FlickrPhotoSelectorTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrPhotoSelectorTableViewController.h"  // self
#import "FlickrFetcher.h"                           // Flickr dictionary keys
#import <MapKit/MapKit.h>                           // annotation creation
#import "MapViewController.h"                       // segue
#import "FlickrPhotoViewController.h"               // segue
#import "FlickrPhotoAnnotation.h"                   //
#import "SegmentedViewController.h"                 // ipad view switching

@interface FlickrPhotoSelectorTableViewController ()
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) NSDictionary* thumbnailImages;
@end

@implementation FlickrPhotoSelectorTableViewController

# pragma mark - Setters and getters
- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self updateMapAnnotations];
    [self.tableView reloadData];
}

- (void)setPlace:(NSDictionary *)place {
    _place = place;
    [self getPhotos];
}

- (Reachability*)reach {
    if (!_reach) { // init if doesn't exist
        _reach = [Reachability reachabilityWithHostname:@"www.flickr.com"];
        [_reach startNotifier]; // TODO: Is this necessary?
    }
    return _reach;
}

- (void)getPhotos {
    [self.refreshControl beginRefreshing];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        if (self.reach.isReachable)
            self.photos = [FlickrFetcher photosInPlace:self.place maxResults:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    });
    // TODO: Give a warning if there is no Internet connection
}

- (NSDictionary*)thumbnailImages {
    if (!_thumbnailImages) { // init if doesn't exist
        _thumbnailImages = [[NSDictionary alloc] init];
    }
    return _thumbnailImages;
}

- (NSArray *)mapAnnotations {
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:
                                   [self.photos count]];
    for (NSDictionary *photo in self.photos)
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    return annotations;
}

# pragma mark - Lifecycle methods
// FIXME: Almost complete duplicate of the same method in TopPlacesTable
//  ViewController
- (void)updateMapAnnotations {
    if (self.splitViewController) {
        id detail = [self.splitViewController.viewControllers lastObject];
        detail = [detail getViewControllerWithID:@"MapViewController"];
        if (self.photos) [detail setAnnotations:[self mapAnnotations]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(getPhotos)
                  forControlEvents:UIControlEventValueChanged];
    //    if (!self.splitViewController) [self.spinner startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    // Unselect the selected row if any
	NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    if (self.splitViewController) [self updateMapAnnotations];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
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
    
    // If also no description, then set standard title
    if ([photoTitle isEqualToString:@""]) photoTitle = @"Unknown";
    
    cell.imageView.image = nil; // don't use the image from a reused cell
    
    UIImage* thumbnailImage;
    // Fetch the image if it does not exist
    if (![self.thumbnailImages objectForKey:photo] && self.reach.isReachable)
        [self fetchThumbnailForPhoto:photo atIndexPath:indexPath];
    
    thumbnailImage = [self.thumbnailImages objectForKey:photo];
    // Set the image if it does exist
    if (thumbnailImage) cell.imageView.image = thumbnailImage;
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;
    return cell;
}

// Asyncronously fetch the thumbnail image for the photo in the row indexPath.row
- (void)fetchThumbnailForPhoto:(NSDictionary*)photo
                   atIndexPath:(NSIndexPath*)indexPath {
    if (self.reach.isReachable) {
        __block UIImage* photoImage;
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                               NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *photoURL = [FlickrFetcher urlForPhoto:photo format:
                               FlickrPhotoFormatSquare];
            NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
            photoImage = [UIImage imageWithData:imageData];
            NSMutableDictionary* mutableThumbnailImages;
            if (photoImage) { // Store the photo in the dictionary
                mutableThumbnailImages = [self.thumbnailImages mutableCopy];
                [mutableThumbnailImages setObject:photoImage forKey:photo];
                self.thumbnailImages = [mutableThumbnailImages copy];
            }
            else photoImage = [self.thumbnailImages objectForKey:photo];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the cell now that the image is stored
                [self.tableView
                 reloadRowsAtIndexPaths:@[indexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        });
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* selectedPhoto = [self.photos objectAtIndex:indexPath.row];
    if (self.splitViewController) { // ipad
        id detail = [self.splitViewController.viewControllers lastObject];
        [detail changeToViewControllerNamed:@"PhotoViewController"];
        detail = [detail getViewControllerWithID:@"PhotoViewController"];
        [(id)detail setPhoto:selectedPhoto];
    }
}

#pragma mark - Other view controllers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController
         setPhoto:[self.photos objectAtIndex:indexPath.row]];
    }
    else if ([segue.identifier isEqualToString:@"showMap"]) {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}
@end
