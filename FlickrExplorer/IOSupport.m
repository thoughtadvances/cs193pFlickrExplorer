//
//  IOSupport.m
//  FlickrExplorer
//
//  Created by admin on 18/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import "IOSupport.h"

@implementation IOSupport

+ (NSArray*)arrayOfFileURLsInDirectory:(NSURL*)scanDirectory {
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator =
    [localFileManager enumeratorAtURL:scanDirectory
           includingPropertiesForKeys: @[NSURLNameKey, NSURLIsDirectoryKey]
                              options: NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler: nil];
    
    NSMutableArray* files = [NSMutableArray array];
    
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL* URL in enumerator) {
        NSNumber* isDirectory;
        [URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey
                        error:NULL];
        
        if (![isDirectory boolValue]) [files addObject:URL];
    }
    return files;
}

+ (NSURL*)oldestAccessedFileInDirectory:(NSURL*)scanDirectory {
    NSDate* date;
    NSDate* oldestDate = [NSDate date];
    NSURL *oldestFile;
    for (NSURL* URL in [IOSupport arrayOfFileURLsInDirectory:scanDirectory]) {
        [URL getResourceValue:&date forKey:NSURLContentAccessDateKey error:nil];
        oldestDate = [oldestDate earlierDate:date];
        if ([oldestDate isEqualToDate:date]) oldestFile = URL;
    }
    return oldestFile;
}

+ (NSNumber*)sizeOfDirectory:(NSURL*)scanDirectory {
    NSArray *URLs = [IOSupport arrayOfFileURLsInDirectory:scanDirectory];
    NSNumber *size;
    double totalSize = 0.0;
    for (id URL in URLs) {
        if ([URL isKindOfClass:[NSURL class]]) {
            [URL getResourceValue:&size
                           forKey:NSURLFileSizeKey
                            error:NULL];
            totalSize += [size doubleValue];
        }
    }
    return [NSNumber numberWithDouble:totalSize/pow(2, 20)];
}

+ (NSURL*)applicationDirectory {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    NSURL* dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = [defaultManager
                              URLsForDirectory:NSApplicationSupportDirectory
                              inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0]
                   URLByAppendingPathComponent:bundleID];
        
        // If the directory does not exist, this method creates it.
        NSError* theError = nil;
        if (![defaultManager createDirectoryAtURL:dirPath
                      withIntermediateDirectories:YES
                                       attributes:nil error:&theError])
        {
            // Handle the error.
            
            return nil;
        }
    }
    return dirPath;
}

@end
