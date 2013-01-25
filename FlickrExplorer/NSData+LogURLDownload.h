//
//  NSData+LogURLDownload.h
//  FlickrExplorer
//
//  Created by admin on 25/J/13.
//  Copyright (c) 2013 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LogURLDownload)
+ (id)LogDataWithContentsOfURL:(NSURL *)aURL;
@end
