//
//  Vacation.h
//  FlickrExplorer
//
//  Created by admin on 4/M/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Vacation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *places;
@end

@interface Vacation (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(NSManagedObject *)value;
- (void)removePlacesObject:(NSManagedObject *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
