//
//  TopPlacesTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()
@property NSArray *topPlaces;
@end

@implementation TopPlacesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // FIXME: Fork this into a thread and show progress feedback
    NSArray *topPlaces = [FlickrFetcher topPlaces];
    self.topPlaces = topPlaces; // get the topPlaces
    [super viewDidLoad];
    
    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topPlaces count];
    NSLog(@"count = %u", [self.topPlaces count]);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
