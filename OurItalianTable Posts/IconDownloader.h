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
-(void)didFinishLoadingIcon:(NSData *)iconData withSuccess:(BOOL)success withPostID:(NSString *)postID;
@end

@interface IconDownloader : NSObject;

// public methods
-(id)initWithURL:(NSURL *)url withPostID:(NSNumber *)postID withDelegate:(id<IconDownloaderDelegate>)delegate;

@end
