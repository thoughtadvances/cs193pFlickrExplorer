//
//  Tag.h
//  FlickrExplorer
//
//  Created by admin on 4/M/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Photo *photo;

@end
