//
//  NSData+LogURLDownload.m
//  FlickrExplorer
//
//  Created by admin on 25/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "NSData+LogURLDownload.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import </usr/include/objc/objc-class.h>

@implementation NSData (LogURLDownload)

// TODO: Create a method that takes two selectors and swizzles them
+ (void)load {
    Method dataWithContentsOfURL =
    class_getClassMethod(self, @selector(dataWithContentsOfURL:));
    Method logDataWithContentsOfURL =
    class_getClassMethod(self, @selector(logDataWithContentsOfURL:));
    method_exchangeImplementations(dataWithContentsOfURL,
                                   logDataWithContentsOfURL);
    
}

+ (id)LogDataWithContentsOfURL:(NSURL *)aURL {
    NSLog(@"[NSData dataWithContentsOfURL:] called");
    return [self LogDataWithContentsOfURL:aURL];
}
@end