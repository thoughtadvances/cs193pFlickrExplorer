//
//  DetailViewController.h
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

// A generic class to be used as the detail view controller of a
//  UISplitViewController so that it does the toolbar button dance properly
// If your root detail UIViewController is not a UINavigationController, then
//  replace the below superclass with the class of your root detail controller

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface DetailViewController : UIViewController
<SplitViewBarButtonItemPresenter>
//- (void)childPresented;
@end
