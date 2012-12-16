//
//  GetFileFromRemoteURL.h
//  Our Italian Table Posts
//
//  Created by Joseph Becci on 6/23/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetFileFromRemoteURLDelegate <NSObject>;
-(void)didReturnRemoteFillDate:(NSString *)remoteDate;
-(void)didFinishLoadingURL:(NSData *)XMLfile withSuccess:(BOOL)success;
@end

@interface GetFileFromRemoteURL : NSObject <NSURLConnectionDelegate>
-(id)initWithURL:(NSURL *)url withDelegate:(id <GetFileFromRemoteURLDelegate>)delegate;
@end
