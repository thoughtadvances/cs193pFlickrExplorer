//
//  TopPlacesTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrTopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoSelectorTableViewController.h"
#import "MapViewController.h"

@interface FlickrTopPlacesTableViewController ()
// TODO: Create a custom data Class TACountry which stores this more easily
// Flickr countries presented in the table view
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) NSDictionary *selectedPlace;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrTopPlacesTableViewController

- (void)setCountries:(NSArray *)countries {
    _countries = countries;
    [self.tableView reloadData];
}

// Take an NSArray from Flickr API of top places and reorder it into an
//  NSArray of NSDictionaries of
+ (NSArray *)makeArrayOfTopPlacesByCountry:(NSArray *)topPlaces {
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

// FIXME: Why doesn't the spinner show up?  Is it because I have no network, so
//  it completes the downloadQueue so quickly that the spinner is removed before
- (void)getCountries {
    [self.spinner startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        self.countries = [FlickrTopPlacesTableViewController
                          makeArrayOfTopPlacesByCountry:
                          [FlickrFetcher topPlaces]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    });
}

- (void)viewDidLoad { // get the top Places
    [super viewDidLoad];
    self.spinner.hidesWhenStopped = YES;
    self.splitViewController.presentsWithGesture = NO;
    [self getCountries];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Number of sections is the  number of countries
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section
{ // Number of rows in a section is the number of places in that country
    NSDictionary *country = [self.countries objectAtIndex:section];
    return [[country objectForKey:@"places"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section {
    // The header for the section is the region name -- get this from the region
    //  at the section index.
    NSDictionary *country = [self.countries objectAtIndex:section];
    return [country objectForKey:@"name"];
}

// Define what to do to present each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier forIndexPath:indexPath];
    
    // Get the program corresponding to the row
    NSDictionary *country = [self.countries objectAtIndex:indexPath.section];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath
{
    NSDictionary *country = [self.countries objectAtIndex:indexPath.section];
    NSArray *places = [country objectForKey:@"places"];
    self.selectedPlace = [places objectAtIndex:indexPath.row];
    // This segue must be manual because otherwise the segue is called
    //      before the indexPath is updated
    // TODO: Can this be put in the storyboard by creating an auto segue from
    //  the dnamic table cell prototype to the destination UIViewController?
    [self performSegueWithIdentifier:@"PlacePhotos" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // go to the
    if ([segue.identifier isEqualToString:@"PlacePhotos"]) {
        [segue.destinationViewController setTitle:[self.selectedPlace
                                                   objectForKey:
                                                   FLICKR_PLACE_NAME]];
    }
    if ([segue.identifier isEqualToString:@"showMap"]) {
        [segue.destinationViewController setAnnotations:self.countries];
    }
    else NSLog(@"Unidentified segue of identifier %@ called", segue.identifier);
}

@end
