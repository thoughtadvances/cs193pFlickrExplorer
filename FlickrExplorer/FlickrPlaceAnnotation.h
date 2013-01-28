//
//  FlickrPlaceAnnotation.h
//  FlickrExplorer
//
//  Created by admin on 26/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>
// Takes a Flickr place dictinoary and creates an annotation from it
+ (FlickrPlaceAnnotation*)annotationForPlace:(NSDictionary*)place;
@property (nonatomic, strong) NSDictionary *place; // Flickr place dictionary
@end
