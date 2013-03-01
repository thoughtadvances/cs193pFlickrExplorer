//
//  SegmentedViewController.h
//  FlickrExplorer
//
//  Created by admin on 23/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

// This is a reusable UIViewController which allows switching between
//  UIViewControllers like a UITabBarViewController, but the buttons
//  are at the top of the screen instead of the bottom

@interface SegmentedViewController : DetailViewController

// An Array of UIViewControllers which are the view controllers in the
//  UISegmentedButton, from left to right
@property (nonatomic, readonly) NSArray* viewControllers;

// Programatically switch to the segment whose UIViewController's ID is
//  viewControllerName.  viewControllerName must be defined in the
//  VIEW_CONTROLLER_NAMES #define in SegmentedViewController.m
- (void)changeToViewControllerNamed:(NSString*)viewControllerName;

// Return the view controller whose Storyboard ID is viewControllerID
- (UIViewController*)getViewControllerWithID:(NSString*)viewControllerID;

// The view controller associated with the currently selected segment
@property (nonatomic, readonly) UIViewController* selectedViewController;
@end
