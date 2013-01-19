//
//  DetailViewController.m
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UISplitViewControllerDelegate>
@end

@implementation DetailViewController

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem*)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        if (splitViewBarButtonItem) {
            [self.navigationItem setLeftBarButtonItem:splitViewBarButtonItem];
        }
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad called");
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

@end