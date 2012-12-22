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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [self recentPhotos];
	// Do any additional setup after loading the view.
}

@end
