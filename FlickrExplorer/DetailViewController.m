//
//  DetailViewController.m
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UISplitViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UIToolbar* toolbar;
@end

@implementation DetailViewController

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        // Update only if the old is different from the new
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) { // Remove old button if it exists
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if (splitViewBarButtonItem) { // Add new button if it exists
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

@end