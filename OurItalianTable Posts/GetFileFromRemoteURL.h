//
//  GetFileFromRemoteURL.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 6/23/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"

@protocol GetFileFromRemoteURLDelegate <NSObject>;

-(void)didReturnRemoteFillDate:(NSString *)remoteDate;
-(void)didFinishLoadingURL:(NSData *)XMLfile
               withSuccess:(BOOL)success;

@end

@interface GetFileFromRemoteURL : NSObject <NSURLConnectionDelegate>

-(id)initWithURL:(NSURL *)url
    withDelegate:(id <GetFileFromRemoteURLDelegate>)delegate;

@end
