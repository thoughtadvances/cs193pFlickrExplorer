//
//  IOSupport.h
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IOSupport : NSObject
+ (NSURL*)applicationDirectory; // URL of the application's directory
// Array of all non-hidden URLs in scanDirectory
+ (NSArray*)arrayOfFileURLsInDirectory:(NSURL*)scanDirectory;
// Total size of all files inside scanDirectory in megabytes
+ (NSNumber*)sizeOfDirectory:(NSURL*)scanDirectory;
// Path to the file accessed the longest time ago in scanDirectory
+ (NSURL*)oldestAccessedFileInDirectory:(NSURL*)scanDirectory;
@end
