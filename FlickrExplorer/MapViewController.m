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
#import "FlickrPhotoSelectorTableViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSelector;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
}

- (void)updateMapView {
    if (self.mapView.annotations) [self.mapView
                                   removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *view = [mapView
                              dequeueReusableAnnotationViewWithIdentifier:
                              @"MapVC"];
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:@"MapVC"];
        view.canShowCallout = YES;
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:
                                         CGRectMake(0, 0, 30, 30)];
        view.rightCalloutAccessoryView = [UIButton buttonWithType:
                                          UIButtonTypeDetailDisclosure];
    }
    view.annotation = annotation;
    [(UIImageView *)view.leftCalloutAccessoryView setImage:nil];
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"showMapPhoto" sender:view.annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:
(MKAnnotationView *)view {
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *image = [self.delegate mapViewController:self
                                       imageForAnnotation:view.annotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
        });
    });
}

- (void)setMapType {
    NSInteger choice = self.mapTypeSelector.selectedSegmentIndex;
    if (choice == 0) self.mapView.mapType = MKMapTypeStandard;
    else if (choice == 1) self.mapView.mapType = MKMapTypeSatellite;
    else self.mapView.mapType = MKMapTypeHybrid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapTypeSelector.selectedSegmentIndex = 0;
    [self.mapTypeSelector addTarget:self.mapView
                             action:@selector(setMapType:)
                   forControlEvents:UIControlEventValueChanged];
    if (self.splitViewController) {
        UIViewController* master = [self.splitViewController.viewControllers
                                    objectAtIndex:0];
        if ([master isKindOfClass:[UITabBarController class]]) {
            master = [(UITabBarController*)master selectedViewController];
        }
        if ([master isKindOfClass:[UINavigationController class]]) {
            master = [(UINavigationController*)master topViewController];
        }
        self.title = [master.navigationItem.title
                      stringByAppendingString:@" Map"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Show all annotations on screen
    double maxLatitude = 0;
    double minLatitude = 0;
    double maxLongitude = 0;
    double minLongitude = 0;
    for (id<MKAnnotation> annotation in self.annotations) { // get bounds
        if (annotation.coordinate.latitude) {
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMapPhoto"]) {
        FlickrPhotoAnnotation *flickrAnnotation =
        (FlickrPhotoAnnotation *)sender;
        [segue.destinationViewController setPhoto:flickrAnnotation.photo];
    }
    else if ([segue.identifier isEqualToString:@"showTablePhoto"])
        [segue.destinationViewController setPhoto:[sender selectedPhoto]];
}

@end
