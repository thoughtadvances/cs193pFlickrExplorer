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
    [defaults synchronize];
    return [defaults objectForKey:RECENT_PHOTOS];
}

- (void)viewWillAppear:(BOOL)animated { // update photos on every showing
    NSArray *recentPhotos = [self recentPhotos];
    if (![recentPhotos isEqualToArray:self.photos]) {
        self.photos = recentPhotos; // get new recents
    }
}

@end