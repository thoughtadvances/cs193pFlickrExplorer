//
//  TopPlacesTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "FlickrTopPlacesTableViewController.h"      // self
#import "FlickrFetcher.h"                           // get Flickr network data
#import "FlickrPhotoSelectorTableViewController.h"
#import "MapViewController.h"

@interface FlickrTopPlacesTableViewController ()
@end

@implementation FlickrTopPlacesTableViewController
- (void)getCountries {
    [self.refreshControl beginRefreshing]; // start loading indicator
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        if (self.reach.isReachable) self.places = [FlickrFetcher topPlaces];
        else {}// TODO: Warn the user
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // finished
        });
    });
}

# pragma mark - Lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(getCountries)
                  forControlEvents:UIControlEventValueChanged];
    __weak FlickrTopPlacesTableViewController* weakSelf = self;
    self.reach.reachableBlock = ^(Reachability* reach) {
        [weakSelf getCountries];
    };
    //    [self getCountries];
}
@end
