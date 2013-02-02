//
//  MapViewController.h
//  ShutterBug
//
//  Created by admin on 15/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// This call expects all annotation objects set in the annotations NSArray
//  to have a "coordinate" @property
// If the annotation is of type FlickrPhotoAnnotation, then it is also expected
//  to have a "photo" @property which is sent to PhotoViewController

@class MapViewController;

//@protocol MapViewControllerDelegate <NSObject>
//- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:
//(id <MKAnnotation>)annotation;
//@end

@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
//@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@end