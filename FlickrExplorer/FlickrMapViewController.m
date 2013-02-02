//
//  FlickrMapViewController.m
//  FlickrExplorer
//
//  Created by admin on 2/F/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "FlickrMapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrPhotoSelectorTableViewController.h"
#import "FlickrTopPlacesTableViewController.h"
#import "SegmentedViewController.h"
#import "ViewControllerSupport.h"
#import "FlickrFetcher.h"

@implementation FlickrMapViewController
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
            UIImage *image = [self imageForAnnotation:view.annotation];
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

- (UIImage *)imageForAnnotation:(id<MKAnnotation>)annotation {
    FlickrPhotoAnnotation *flickrAnnotation = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:flickrAnnotation.photo format:
                  FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

@end
