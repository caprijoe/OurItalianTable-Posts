//
//  IconDownloader.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//
#import "AtomicGetFileFromRemoteURL.h"

#define POST_ICON_HEIGHT        48

@protocol iconDownloaderDelegate <NSObject>

-(void)iconDownloadComplete:(NSData *)iconData forPostID:(int64_t)postID withSucess:(BOOL)success;

@end

@interface IconDownloader : NSObject <AtomicGetFileFromRemoteURLDelegate>

-(id)initWithURL:(NSString *)incomingURLString forPostID:(int64_t)postID withDelegate:(id<iconDownloaderDelegate>)delegate;

@end
