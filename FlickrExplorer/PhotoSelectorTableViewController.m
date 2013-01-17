//
//  PhotoSelectorTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoSelectorTableViewController.h"
#import "FlickrPhotoViewController.h" // segue to it
#import "FlickrFetcher.h" // define keys

#define PHOTO_TITLE_KEY FLICKR_PHOTO_TITLE
#define PHOTO_DESCRIPTION_KEY FLICKR_PHOTO_DESCRIPTION

@interface PhotoSelectorTableViewController ()
@property (nonatomic, strong) NSDictionary *selectedPhoto;
@end

@implementation PhotoSelectorTableViewController

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.splitViewController) { // keep selection on iPad
        self.clearsSelectionOnViewWillAppear = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count]; // Number of rows is the number of photos
}

// Called to populate cells
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier
                             forIndexPath:indexPath];
    
    // get corresponding photo, in order from most recent to least recent
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    id photoTitle = [photo objectForKey:PHOTO_TITLE_KEY];
    id photoDescription = [photo objectForKey:PHOTO_DESCRIPTION_KEY];
    
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
    
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.photos objectAtIndex:indexPath.row];
    if (self.splitViewController) { // iPad
        FlickrPhotoViewController *detail =
        [self.splitViewController.viewControllers lastObject];
        [detail setPhoto:self.selectedPhoto];
    } else [self performSegueWithIdentifier:@"Photo" sender:self]; // iPhone
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Photo"]) {
        // Send the new photo as the NSDictionary
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    }
}

@end
