//
//  FlickrPlaceAnnotation.m
//  FlickrExplorer
//
//  Created by admin on 26/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation
+ (FlickrPlaceAnnotation*)annotationForPlace:(NSDictionary *)place {
    FlickrPlaceAnnotation* annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSString*)title {
    return [self.place objectForKey:FLICKR_PLACE_NAME];
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE]
                           doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE]
                            doubleValue];
    return coordinate;
}
@end