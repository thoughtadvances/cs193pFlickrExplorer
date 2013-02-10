//
//  FlickrPhotoSelectorTableViewController.h
//  FlickrExplorer
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

// Take an NSArray of NSDictionaries containing information about photos and
//  display these photos in a UITableViewController

@interface FlickrPhotoSelectorTableViewController : UITableViewController
// NSArray of Flickr NSDictionary photo information
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *place;
// The Flickr photo NSDictionary of the photo that was selected
@property (nonatomic, strong) NSDictionary *selectedPhoto;
// Internet connection testing for subclasses to access
@property (nonatomic, strong) Reachability* reach;
@end
