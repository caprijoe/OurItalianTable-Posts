//
//  IconDownloader.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//
#import <UIKit/UIKit.h>

#define POST_ICON_HEIGHT        48

@protocol IconDownloaderDelegate <NSObject>
-(void)didFinishLoadingURL:(NSData *)XMLfile withSuccess:(BOOL)success findingMetadata:(NSString *)date;
@end

@interface NewIconDownloader : NSObject;

// public methods
-(id)initWithURL:(NSURL *)url withPostID:(NSNumber *)postID withDelegate:(id<IconDownloaderDelegate>)delegate;

@end
