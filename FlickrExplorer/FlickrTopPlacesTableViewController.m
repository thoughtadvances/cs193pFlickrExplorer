//
//  TopPlacesTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrTopPlacesTableViewController.h"
#import "FlickrFetcher.h" // to be able to get data
#import "PhotoSelectorTableViewController.h" // to be able to segue to it

@interface FlickrTopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic, strong) NSDictionary *selectedPlace;
@end

@implementation FlickrTopPlacesTableViewController

- (void)viewDidLoad
{
    // FIXME: Fork this into a thread and show progress feedback
    self.topPlaces = [FlickrFetcher topPlaces]; // get the topPlaces
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section
{
    return [self.topPlaces count];
}

// Define what to do to present each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier forIndexPath:indexPath];
    
    // Get the program corresponding to the row
    NSDictionary *topPlace = [self.topPlaces objectAtIndex:indexPath.row];
    // Default locations in case of Flickr data failure
    NSString *specificLocation = @"Unknown Location";
    NSString *generalLocation = @"";
    // Get Flickr location information
    NSString *placeDescription = [topPlace objectForKey:@"_content"];
    
    // Separate into components
    NSArray *descriptionComponents = [placeDescription
                                      componentsSeparatedByString:@","];
    
    // cell main title
    if ([descriptionComponents count]) { // There is some location data
        specificLocation = [descriptionComponents objectAtIndex:0];
    }
    
    // The remaining descriptors go in the subtitle
    for (int i = 1; i < [descriptionComponents count]; i++) {
        generalLocation = [generalLocation stringByAppendingString:
                           [descriptionComponents objectAtIndex:i]];
        if (!(i == [descriptionComponents count] - 1)) {
            generalLocation = [generalLocation stringByAppendingString:@","];
        }
    }
    // Put the text into the table cell
    cell.textLabel.text = specificLocation;
    cell.detailTextLabel.text = generalLocation;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath
{
    self.selectedPlace = [self.topPlaces objectAtIndex:indexPath.row];
    // This segue must be manual because otherwise the segue is called
    //      before the indexPath is updated
    [self performSegueWithIdentifier:@"PlacePhotos" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // go to the
    if ([segue.identifier isEqualToString:@"PlacePhotos"]) {
        // Get photo information for selected place and send to destination
        [segue.destinationViewController setPhotos:
         [FlickrFetcher photosInPlace:self.selectedPlace maxResults:5]];
        // Title should be the location of the photos
        [segue.destinationViewController setTitle:[self.selectedPlace
                                                 objectForKey:
                                                 FLICKR_PLACE_NAME]];
    }
}

@end
