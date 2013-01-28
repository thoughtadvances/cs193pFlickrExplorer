//
//  SegmentedViewController.m
//  FlickrExplorer
//
//  Created by admin on 23/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "SegmentedViewController.h"

@interface SegmentedViewController ()
//@property (weak, nonatomic) IBOutlet UIToolbar* toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (weak, nonatomic) IBOutlet UIView* contentView;
@property (nonatomic, strong, readwrite) UIViewController* selectedViewController;
@property (nonatomic, strong, readwrite) NSArray* viewControllers;
@end

@implementation SegmentedViewController

// Make this an array of NSStrings of the identifiers of the viewControllers
//  that this class will display
#define VIEW_CONTROLLER_NAMES @"MapViewController", @"PhotoViewController"

- (UIViewController*)getViewControllerWithID:(NSString *)viewControllerID {
    int i = 0;
    for (NSString* controllerID in @[VIEW_CONTROLLER_NAMES]) {
        if ([controllerID isEqualToString:viewControllerID]) {
            return [self viewControllerForSegmentIndex:i];
        }
        i++;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // add viewController so you can switch them later.
    UIViewController *vc = [self viewControllerForSegmentIndex:
                            self.segmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;
    [self.contentView addSubview:vc.view];
    self.selectedViewController = vc;
}

- (void)viewWillLayoutSubviews { // resize view to fit new dimensions
    [super viewWillLayoutSubviews];
    self.selectedViewController.view.frame = self.contentView.bounds;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:
                            sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    [self transitionFromViewController:self.selectedViewController
                      toViewController:vc duration:0.5 options:
     UIViewAnimationOptionTransitionCrossDissolve animations:^{
         [self.selectedViewController.view removeFromSuperview];
         vc.view.frame = self.contentView.bounds;
         [self.contentView addSubview:vc.view];
     } completion:^(BOOL finished) {
         [vc didMoveToParentViewController:self];
         [self.selectedViewController removeFromParentViewController];
         self.selectedViewController = vc;
     }];
    //    self.navigationItem.title = vc.title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSArray* viewControllerNames = @[VIEW_CONTROLLER_NAMES];
    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    for (id viewControllerName in viewControllerNames) {
        UIViewController* newController =
        [self.storyboard instantiateViewControllerWithIdentifier:
         viewControllerName];
        [viewControllers addObject:newController];
    }
    self.viewControllers = [viewControllers copy];
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    return [self.viewControllers objectAtIndex:index];
}

- (void)changeToViewControllerNamed:(NSString*)viewControllerName {
    int i = 0;
    for (id name in @[VIEW_CONTROLLER_NAMES]) {
        if ([name isEqualToString:viewControllerName]) {
            if (self.segmentedControl.selectedSegmentIndex != i) {
                self.segmentedControl.selectedSegmentIndex = i;
                [self segmentChanged:self.segmentedControl];
            }
            break;
        }
        i++;
    }
}

@end
