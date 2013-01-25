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

//void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel) {
//    Method orig_method = nil, alt_method = nil;
//    // First, look for the methods
//    orig_method = class_getInstanceMethod(aClass, orig_sel);
//    alt_method = class_getInstanceMethod(aClass, alt_sel);
//    // If both are found, swizzle them
//    if ((orig_method != nil) && (alt_method != nil))
//    {
//        char temp1;
//        IMP temp2;
//        temp1 = orig_method->method_types;
//        orig_method->method_types = alt_method->method_types;
//        alt_method->method_types = temp1;
//        temp2 = orig_method->method_imp;
//        orig_method->method_imp = alt_method->method_imp;
//        alt_method->method_imp = temp2;
//    }
//}
//
//// TODO: Are the two following methods equivalent?
//+ (void)load {
//    MethodSwizzle();
//}

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