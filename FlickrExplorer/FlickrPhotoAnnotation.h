//
//  FlickrPhotoAnnotation.h
//  ShutterBug
//
//  Created by admin on 15/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>
// Takes a Flickr photo dictionary and creates an annotation from it
+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo;
@property (nonatomic, strong) NSDictionary *photo; // Flickr photo dictionary
@end
