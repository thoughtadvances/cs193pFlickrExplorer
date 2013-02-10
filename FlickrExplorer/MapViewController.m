//
//  MapViewController.m
//  ShutterBug
//
//  Created by admin on 15/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "MapViewController.h"
#import "DetailViewController.h"
#import "FlickrFetcher.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSelector;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController
- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
}

- (void)updateMapView {
    if (self.mapView) {
        if (self.mapView.annotations) [self.mapView
                                       removeAnnotations:
                                       self.mapView.annotations];
        if (self.annotations && [self.annotations count] != 0) {
            [self.mapView addAnnotations:self.annotations];
            [self setMapViewRegion];
        }
    }
}

- (void)setMapType { // UISegementedButton pressed
    NSInteger choice = self.mapTypeSelector.selectedSegmentIndex;
    if (choice == 0) self.mapView.mapType = MKMapTypeStandard;
    else if (choice == 1) self.mapView.mapType = MKMapTypeSatellite;
    else self.mapView.mapType = MKMapTypeHybrid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.splitViewController.presentsWithGesture = NO;
    self.mapTypeSelector.selectedSegmentIndex = 0;
    [self.mapTypeSelector addTarget:self
                             action:@selector(setMapType)
                   forControlEvents:UIControlEventValueChanged];
}

- (void)setMapViewRegion {
    // Show all annotations on screen
    // Set to max possible values so that any real coordinate will always
    //  make the following conditions true on the first pass
    double maxLatitude = -90;
    double minLatitude = 90;
    double maxLongitude = -180;
    double minLongitude = 180;
    for (id<MKAnnotation> annotation in self.annotations) { // get bounds
        if (annotation.coordinate.latitude) {
            NSLog(@"Coordinates: %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
            if (annotation.coordinate.latitude > maxLatitude)
                maxLatitude = annotation.coordinate.latitude;
            else if (annotation.coordinate.latitude < minLatitude)
                minLatitude = annotation.coordinate.latitude;
            if (annotation.coordinate.longitude > maxLongitude)
                maxLongitude = annotation.coordinate.longitude;
            else if (annotation.coordinate.longitude < minLongitude)
                minLongitude = annotation.coordinate.longitude;
        }
        NSLog(@"maxLongitude = %g", maxLongitude);
    }
    
    // width and height
    CLLocationCoordinate2D bottomLeftPoint = {minLatitude, minLongitude};
    CLLocationCoordinate2D topRightPoint = {maxLatitude, maxLongitude};
    double latitudeDelta = fabs(topRightPoint.latitude -
                                bottomLeftPoint.latitude);
    double longitudeDelta = fabs(topRightPoint.longitude -
                                 bottomLeftPoint.longitude);
    // padding
    latitudeDelta += latitudeDelta * 0.6;
    longitudeDelta += longitudeDelta * 0.2;
    // center
    double latitudeCenter = (maxLatitude + minLatitude ) / 2;
    double longitudeCenter = (maxLongitude + minLongitude) / 2;
    CLLocationCoordinate2D center = {latitudeCenter, longitudeCenter};
    // set it
    [self.mapView setRegion:MKCoordinateRegionMake(center, MKCoordinateSpanMake(latitudeDelta, longitudeDelta))];
    
}

@end
