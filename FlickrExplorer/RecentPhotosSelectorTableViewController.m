//
//  RecentPhotosSelectorTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 22/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "RecentPhotosSelectorTableViewController.h"
#import "FlickrExplorerAppDelegate.h" // NSUserDefaults defines

@implementation RecentPhotosSelectorTableViewController

@synthesize reach = _reach; // synthesize inherited @property

- (Reachability*)reach {
    if (!_reach) { // init if doesn't exist
        _reach = [Reachability reachabilityWithHostname:@"www.flickr.com"];
        [_reach startNotifier]; // TODO: Is this necessary?
    }
    return _reach;
}
- (NSArray *)getRecentPhotos { // get recent photos NSUserDefaults preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    return [defaults objectForKey:RECENT_PHOTOS];
}

# pragma mark - Lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(getRecentPhotos)
                  forControlEvents:UIControlEventValueChanged];
}
- (void)viewWillAppear:(BOOL)animated { // update photos on every showing
    [super viewWillAppear:animated];
    NSArray *recentPhotos = [self getRecentPhotos];
    if (![recentPhotos isEqualToArray:self.photos]) {
        self.photos = recentPhotos; // get new recents
    }
}
@end
