//
//  TASpinner.m
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "TASpinner.h"

@implementation TASpinner

// TODO: Metaprogram it so that it replaces all instances of `self` with
//  `sender`
// TOOD: Is there any way to enforce that something calling this method has
//  an object spinner?
// TODO: Force it to assume that sender has a spinner @property?

+ (void)concurrentlyExecute:(void (^)(void))concurrentBlock
    afterwardsExecuteInMain:(void (^)(void))mainBlock
                   onSender:(id)sender {
//    if (sender.spinner) [sender.spinner startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader",
                                                           NULL);
    dispatch_async(downloadQueue, ^{
        concurrentBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            mainBlock();
//            if (sender.spinner) [sender.spinner stopAnimating];
        });
    });

}

@end
