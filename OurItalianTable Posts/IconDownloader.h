//
//  IconDownloader.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//
#import "AtomicGetFileFromRemoteURL.h"

#define POST_ICON_HEIGHT        48

@protocol IconDownloaderDelegate <AtomicGetFileFromRemoteURLDelegate>

@end

@interface IconDownloader : AtomicGetFileFromRemoteURL;

@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSURL *url;

-(id)init;
-(void)startFileDownload;

@end
