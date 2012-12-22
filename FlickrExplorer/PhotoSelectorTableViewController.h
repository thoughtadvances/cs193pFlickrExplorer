//
//  PhotoSelectorTableViewController.h
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>

// Take an NSArray of NSDictionaries containing information about photos and
//  display these photos in a UITableViewController

@interface PhotoSelectorTableViewController : UITableViewController
// NSArray of NSDictionary photos information
@property (nonatomic, strong) NSArray *photos;
@end
