//
//  ViewControllerSupport.m
//  FlickrExplorer
//
//  Created by admin on 22/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "ViewControllerSupport.h"

@implementation ViewControllerSupport
// TODO: Make this a category method for the UIViewController rather than a new
//  class
// TODO: Is there any way to do this without casting?  Why is all this casting
//  necessary?
+ (UIViewController*)getNonNavigationControllerFor:
(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(UINavigationController*)controller topViewController];
    }
    else if ([controller isKindOfClass:[UISplitViewController class]]) {
        controller = [[(UISplitViewController*)controller viewControllers]
                      lastObject];
    }
    else if ([controller isKindOfClass:[UITabBarController class]]) {
        controller = [(UITabBarController*)controller selectedViewController];
    }
    else if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(UINavigationController*)controller topViewController];
    }
    if ([controller isKindOfClass:[UISplitViewController class]] ||
        [controller isKindOfClass:[UITabBarController class]] ||
        [controller isKindOfClass:[UINavigationController class]]) {
        return [ViewControllerSupport getNonNavigationControllerFor:
                controller];
    }
    else return controller;
}

// Move this to a more general library to work on all obejcts, not just
//  UIViewControllers
+ (UIViewController*)viewControllerOfType:(Class)class inArray:(NSArray*)array {
    for (id object in array) {
        if ([object isKindOfClass:class]) return object;
    }
    return nil;
}

@end
