//
//  Place.h
//  FlickrExplorer
//
//  Created by admin on 4/M/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Vacation;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) Vacation *vacation;
@property (nonatomic, retain) Photo *photos;

@end
