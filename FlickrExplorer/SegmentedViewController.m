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
@property (strong, nonatomic) UIViewController* currentViewController;
@property (weak, nonatomic) IBOutlet UIView* contentView;
@property (nonatomic, strong) NSArray* viewControllers;
@end

@implementation SegmentedViewController

// Make this an array of NSStrings of the identifiers of the viewControllers
//  that this class will display
#define VIEW_CONTROLLER_NAMES @"MapViewController", @"PhotoViewController"

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // add viewController so you can switch them later.
    UIViewController *vc = [self viewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;
    [self.contentView addSubview:vc.view];
    self.currentViewController = vc;
}

- (void)viewWillLayoutSubviews {
    self.currentViewController.view.frame = self.contentView.bounds;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentViewController toViewController:vc duration:0.5 options:
     UIViewAnimationOptionTransitionCrossDissolve animations:^{
         [self.currentViewController.view removeFromSuperview];
         vc.view.frame = self.contentView.bounds;
         [self.contentView addSubview:vc.view];
     } completion:^(BOOL finished) {
         [vc didMoveToParentViewController:self];
         [self.currentViewController removeFromParentViewController];
         self.currentViewController = vc;
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

@end
