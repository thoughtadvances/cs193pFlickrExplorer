//
//  FlickrPlacesTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrPlacesTableViewController.h"         // self
#import "FlickrFetcher.h"                           // Flickr dictionary keys
#import "FlickrPhotoSelectorTableViewController.h"  // segue
#import "MapViewController.h"                       // segue
#import "FlickrPlaceAnnotation.h"                   // create map annotations

@interface FlickrPlacesTableViewController ()
// TODO: Create a custom data Class TACountry which stores this more easily
// Flickr countries presented in the table view

// sorted Flickr places ready for display
@property (nonatomic, strong) NSArray* sortedPlaces;
@end

@implementation FlickrPlacesTableViewController
- (void)setPlaces:(NSArray *)places { // sort new places into sortedPlaces
    _places = places;
    self.sortedPlaces = [FlickrPlacesTableViewController
                         makeArrayOfPlacesByCountry:self.places];
}

- (void)setSortedPlaces:(NSArray *)sortedPlaces { // display new places
    _sortedPlaces = sortedPlaces;
    [self updateMapAnnotations];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (Reachability*)reach {
    if (!_reach) { // init if doesn't exist
        _reach = [Reachability reachabilityWithHostname:@"www.flickr.com"];
        [_reach startNotifier]; // TODO: Is this necessary?
    }
    return _reach;
}

- (NSArray *)mapAnnotations { // create annotations for map
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:
                                   [self.places count]];
    for (NSDictionary *place in self.places) {
        [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
    }
    return annotations;
}

// FIXME: I have almost exact code duplication between this class and
//  PhotoSelectorTableViewController
- (void)updateMapAnnotations {
    if (self.splitViewController) {
        id detail = [self.splitViewController.viewControllers lastObject];
        for (id viewController in [detail viewControllers]) {
            if ([viewController isKindOfClass:[MapViewController class]]) {
                detail = viewController;
                break;
            }
        }
        if (self.sortedPlaces) [detail setAnnotations:[self mapAnnotations]];
    }
}

// Take an NSArray from Flickr API of places and reorder it into an
//  NSArray of NSDictionaries of places sorted alphabetically
+ (NSArray *)makeArrayOfPlacesByCountry:(NSArray *)topPlaces {
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    BOOL inserted = NO;
    // Create an array of all the countries
    for (NSDictionary *place in topPlaces) {
        inserted = NO;
        // Get the country of the place as a string
        NSString *topPlaceName = [place objectForKey:FLICKR_PLACE_NAME];
        NSString *topPlaceCountryName = [[topPlaceName
                                          componentsSeparatedByString:@", "]
                                         lastObject];
        
        // Add the place to the array of countries and places
        for (NSMutableDictionary *country in countries) {
            if ([topPlaceCountryName isEqualToString:
                 [country objectForKey:@"name"]]) { // country exists, add place
                NSMutableArray *places = [country objectForKey:@"places"];
                [places addObject:place];
                inserted = YES;
            }
        }
        if (!inserted) { // create new country and add place
            NSMutableArray *places = [[NSMutableArray alloc] init];
            [places addObject:place];
            NSMutableDictionary *newCountry = [NSMutableDictionary
                                               dictionaryWithObjectsAndKeys:
                                               topPlaceCountryName, @"name",
                                               places, @"places", nil];
            [countries addObject:newCountry];
        }
    }
    // Alphabetize the countries
    NSArray *countryDescriptors = [NSArray arrayWithObjects:
                                   [[NSSortDescriptor alloc]
                                    initWithKey:@"name"
                                    ascending:YES
                                    selector:@selector
                                    (localizedCaseInsensitiveCompare:)] , nil];
    NSArray *sortedCountries = [countries sortedArrayUsingDescriptors:
                                countryDescriptors];
    // Alphabetize the places within each country
    NSArray *placeDescriptors = [NSArray arrayWithObjects:
                                 [[NSSortDescriptor alloc]
                                  initWithKey:FLICKR_PLACE_NAME
                                  ascending:YES
                                  selector:@selector
                                  (localizedCaseInsensitiveCompare:)], nil];
    NSMutableArray *mutableSortedCountries = [sortedCountries mutableCopy];
    for (NSMutableDictionary *country in mutableSortedCountries) {
        NSArray *places = [country objectForKey:@"places"];
        places = [places sortedArrayUsingDescriptors:
                  placeDescriptors];
        [country setObject:places forKey:@"places"];
    }
    return [mutableSortedCountries copy];
}

# pragma mark - Lifecycle methods
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Unselect the selected row if any
	NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    [self updateMapAnnotations];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Number of sections is the  number of countries
    return [self.sortedPlaces count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section
{ // Number of rows in a section is the number of places in that country
    NSDictionary *country = [self.sortedPlaces objectAtIndex:section];
    return [[country objectForKey:@"places"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section {
    // The header for the section is the region name -- get this from the region
    //  at the section index.
    NSDictionary *country = [self.sortedPlaces objectAtIndex:section];
    return [country objectForKey:@"name"];
}

// Define what to do to present each cell
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier forIndexPath:indexPath];
    
    // Get the program corresponding to the row
    NSDictionary *country = [self.sortedPlaces objectAtIndex:indexPath.section];
    NSArray *places = [country objectForKey:@"places"];
    NSDictionary *place = [places objectAtIndex:indexPath.row];
    // Default locations in case of Flickr data failure
    NSString *specificLocation = @"Unknown Location";
    NSString *generalLocation = @"";
    // Get Flickr location information
    NSString *placeDescription = [place objectForKey:FLICKR_PLACE_NAME];
    
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

- (NSDictionary*)placeAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary *country = [self.sortedPlaces objectAtIndex:indexPath.section];
    NSArray *places = [country objectForKey:@"places"];
    return [places objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
//(NSIndexPath *)indexPath
//{
//    // This segue must be manual because otherwise the segue is called
//    //      before the indexPath is updated
//    [self performSegueWithIdentifier:@"PlacePhotos" sender:self];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlacePhotos"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary* selectedPlace = [self placeAtIndexPath:indexPath];
        [segue.destinationViewController
         setTitle:[selectedPlace objectForKey:FLICKR_PLACE_NAME]];
        [segue.destinationViewController setPlace:selectedPlace];
    }
    else if ([segue.identifier isEqualToString:@"showMap"]) {
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController
         setTitle:[self.navigationItem.title stringByAppendingString:@" Map"]];
    }
}
@end
