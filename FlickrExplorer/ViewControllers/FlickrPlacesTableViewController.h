//
//  FlickrPlacesTableViewController.h
//  FlickrExplorer
//
//  Created by admin on 4/M/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h" // check network connection

@interface FlickrPlacesTableViewController : UITableViewController
@property (nonatomic, strong) NSArray* places; // Places from Flickr API
@property (nonatomic, strong) Reachability* reach;  // check network connection
@end
