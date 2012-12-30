//
//  RecentPhotosSelectorTableViewController.m
//  FlickrExplorer
//
//  Created by admin on 22/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "RecentPhotosSelectorTableViewController.h"
#import "FlickrExplorerAppDelegate.h" // NSUserDefaults defines

@interface RecentPhotosSelectorTableViewController ()

@end

@implementation RecentPhotosSelectorTableViewController

- (NSArray *)recentPhotos { // get recent photos NSUserDefaults preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // make sure preferences are up-to-date
    return [defaults objectForKey:RECENT_PHOTOS_KEY];
}

- (void)viewWillAppear:(BOOL)animated { // update photos on every showing
    if (![[self recentPhotos] isEqualToArray:self.photos]) {
        self.photos = [self recentPhotos]; // get new recents
        [self.tableView reloadData]; // show new recents
    }
}

@end
