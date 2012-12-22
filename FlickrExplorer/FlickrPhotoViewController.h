//
//  FlickrPhotoViewController.h
//  FlickrExplorer
//
//  Created by admin on 22/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "PhotoViewController.h"

// Take an NSDictionary describing a Flickr photo, download that photo, convert
//  it, and put it on screen

@interface FlickrPhotoViewController : PhotoViewController
// Flickr NSDictionary of photo information
@property (nonatomic, strong) NSDictionary *photo;
@end
