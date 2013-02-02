//
//  MapViewController.m
//  ShutterBug
//
//  Created by admin on 15/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "MapViewController.h"
#import "FlickrPhotoViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrPhotoSelectorTableViewController.h"
#import "ViewControllerSupport.h"
#import "DetailViewController.h"
#import "SegmentedViewController.h"
#import "FlickrFetcher.h"
#import "FlickrTopPlacesTableViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSelector;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController
- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapView];
    // Update the annotations once the mapView has been set
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
            [self setMapViewRegion]; // TODO: Does setting this here work?
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *view = [mapView
                              dequeueReusableAnnotationViewWithIdentifier:
                              @"MapVC"];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"MapVC"];
        
        view.canShowCallout = YES;
        if ([annotation isKindOfClass:[FlickrPhotoAnnotation class]])
            view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:
                                             CGRectMake(0, 0, 30, 30)];
        view.rightCalloutAccessoryView = [UIButton buttonWithType:
                                          UIButtonTypeDetailDisclosure];
    }
    view.annotation = annotation;
    if ([annotation isKindOfClass:[FlickrPhotoAnnotation class]])
        [(UIImageView *)view.leftCalloutAccessoryView setImage:nil];
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:
(MKAnnotationView *)view {
    // Don't try to get a photo for FlickrPlaceAnnotation objects
    if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]]) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                               NULL);
        dispatch_async(downloadQueue, ^{
            UIImage *image = [self.delegate mapViewController:self
                                           imageForAnnotation:view.annotation];
            if (image)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
                });
        });
    }
    else if ([view.annotation isKindOfClass:[FlickrPlaceAnnotation class]]) {
        
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    // Show the PhotoViewController
    if (self.splitViewController && [view.annotation isKindOfClass:
                                     [FlickrPhotoAnnotation class]]) {
        id detail = [self.splitViewController.viewControllers lastObject];
        [detail changeToViewControllerNamed:@"PhotoViewController"];
        detail = [detail getViewControllerWithID:@"PhotoViewController"];
        [detail setPhoto:[(FlickrPhotoAnnotation*)view.annotation photo]];
    }
    // Move from TopPlaces to PhotoTableView in the master
    else if (self.splitViewController && [view.annotation isKindOfClass:
                                          [FlickrPlaceAnnotation class]]) {        
        id master = [ViewControllerSupport getNonNavigationControllerFor:
                     [self.splitViewController.viewControllers objectAtIndex:0]];
        NSLog(@"master's type = %@", [master class]);
        [master performSegueWithIdentifier:@"PlacePhotos" sender:view.annotation];
    }
    else if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]])
        [self performSegueWithIdentifier:@"showPhoto" sender:view.annotation];
    else if ([view.annotation isKindOfClass:[FlickrPlaceAnnotation class]])
        [self performSegueWithIdentifier:@"PlacePhotos" sender:
         [(FlickrPlaceAnnotation*)view.annotation place]];
    
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
    double maxLatitude = 0;
    double minLatitude = 0;
    double maxLongitude = 0;
    double minLongitude = 0;
    NSLog(@"self.annotations = %@", self.annotations);
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
    }
    // width and height
    CLLocationCoordinate2D bottomLeftPoint = {minLatitude, minLongitude};
    CLLocationCoordinate2D topRightPoint = {maxLatitude, maxLongitude};
    NSLog(@"bottomLeftPoint = %f, %f", bottomLeftPoint.latitude, bottomLeftPoint.longitude);
    NSLog(@"topRightPoints = %f, %f", topRightPoint.latitude, bottomLeftPoint.longitude);
    double width = MKMapPointForCoordinate(topRightPoint).x -
    MKMapPointForCoordinate(bottomLeftPoint).x;
    double height = MKMapPointForCoordinate(topRightPoint).y -
    MKMapPointForCoordinate(bottomLeftPoint).y;
    // center
    double latitudeCenter = (maxLatitude - minLatitude ) / 2;
    double longitudeCenter = (maxLongitude - minLongitude) / 2;
    CLLocationCoordinate2D center = {latitudeCenter, longitudeCenter};
    // set it
    MKMapRect finalRegion = {MKMapPointForCoordinate(center),
        MKMapSizeMake(width, height)};
    [self.mapView setVisibleMapRect:finalRegion
                        edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
                           animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlacePhotos"]) {
        // TODO: Can this be moved to within the FlickrPhotoViewController
        //  class?  Is there somewhere where the title change will be
        //  visible before it comes on screen?
        //        if ([sender respondsToSelector:@selector(selectedPlace)]) {
        //            [segue.destinationViewController setTitle:[[sender selectedPlace]
        //                                                       objectForKey:
        //                                                       FLICKR_PLACE_NAME]];
        
        //        }
        [segue.destinationViewController setPlace:sender];
    }
    else if ([segue.identifier isEqualToString:@"showTablePhoto"])
        [segue.destinationViewController setPhoto:[sender selectedPhoto]];
    else if ([segue.identifier isEqualToString:@"showPhoto"])
        [segue.destinationViewController setPhoto:[sender photo]];
}
@end
