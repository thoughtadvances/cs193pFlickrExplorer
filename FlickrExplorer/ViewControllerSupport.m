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
+ (UIViewController*)getNonNavigationControllerFor:(id)controller {
    if ([controller isKindOfClass:[UINavigationController class]])
        controller = [controller topViewController];
    else if ([controller isKindOfClass:[UISplitViewController class]])
        controller = [[controller viewControllers] lastObject];
    else if ([controller isKindOfClass:[UITabBarController class]])
        controller = [controller selectedViewController];
    else if ([controller isKindOfClass:[UINavigationController class]])
        controller = [controller topViewController];
    if ([controller isKindOfClass:[UISplitViewController class]] ||
        [controller isKindOfClass:[UITabBarController class]] ||
        [controller isKindOfClass:[UINavigationController class]])
        return [ViewControllerSupport getNonNavigationControllerFor:
                controller];
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
