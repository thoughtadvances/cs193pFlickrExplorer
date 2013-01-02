//
//  RotatableViewController.m
//  Psychologist
//
//  Created by admin on 15/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

// Explanation
//  This is a reusable class intended for making it easy to have a rotating
//  UISplitViewController for the iPad which handles the plaement of the button
//  for the master pop-up.  The three files for using it are:
//      RotatableViewController.h
//      RotatableViewController.m
//      SplitViewBarButtonItemPresenter.h

// How to Use
//  After importing the 3 files into your project:
//  - Make your master UIViewController a member of class
//      RotatableViewController
//  - Add a UIToolbar IBOUtlet to the Class implementation of your detail
//      UIViewController: @property (nonatomic) IBOutlet UIToolbar *toolbar;
//  - Add a UIToolbar to your detail UIViewController's storyboard
//  - Hook up the toolbar to this @property
//  - Import the SplitViewBarButtonItemPresenter @protocol in the Class of your
//      detail UIViewController: #import "SplitViewBarButtonItemPresenter.h"
//  - Publicly declare that the Class of your detail UIViewController implements
//      the @protocol: <SplitViewBarButtonItemPresenter>
//  - Privately declare that the Class of your detail UIViewController is
//      the UISplitViewController's delegate: <UISplitViewControllerDelegate>
//  - Explicitly @synthesize splitViewBarButtonItem in the Class of the detail
//      UIViewController:
//      @synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
//  - Set a Title for the master UIViewController in the storyboard using
//      XCode's Attributes Inspector in the storyboard.  This title is used
//      as the button's text.  Or, do this programatically by setting
//      self.title
//  - Override the setter for the splitViewBarButtonItem so that it
//      puts the barButtonItem in the toolbar.  Code should look like this:
//- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
//    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
//        // Update only if the old is different from the new
//        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
//        if (_splitViewBarButtonItem) { // Remove old button if it exists
//            [toolbarItems removeObject:_splitViewBarButtonItem];
//        }
//        if (splitViewBarButtonItem) { // Add new button if it exists
//            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
//        }
//        self.toolbar.items = toolbarItems;
//        _splitViewBarButtonItem = splitViewBarButtonItem;
//    }
//}

#import "RotatableViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RotatableViewController ()

@end

@implementation RotatableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self; // This is the delegate
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter {
    // The SplitViewBarButtonItemPresenter is the detail view
    id detailViewController =
    [self.splitViewController.viewControllers lastObject];
    if (![detailViewController conformsToProtocol:
          @protocol(SplitViewBarButtonItemPresenter)]) {
        detailViewController = nil;
    }
    return detailViewController;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    // Hide the master if the detail implements
    //  @protocol(splitViewBarButtonItemPresenter)
    return [self splitViewBarButtonItemPresenter] ?
    UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc {
    //
    barButtonItem.title = self.title; // Title of the UIViewController
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem =
    barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
