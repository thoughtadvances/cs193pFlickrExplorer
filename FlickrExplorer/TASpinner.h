//
//  TASpinner.h
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TASpinner;

//@protocol TASpinnerDelegate <NSObject>
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
//@end

@interface TASpinner : NSObject
+ (void)concurrentlyExecute:(void(^)(void))concurrentBlock
    afterwardsExecuteInMain:(void(^)(void))mainBlock
                   onSender:(id)sender;
//@property (nonatomic, weak) id <TASpinnerDelegate> delegate;
@end