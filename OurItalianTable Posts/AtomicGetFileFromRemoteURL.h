//
//  AtomicGetFileFromRemoteURL.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"
#define TIMEOUT_SECONDS                 20.0

@protocol AtomicGetFileFromRemoteURLDelegate <NSObject>;

// call back when file load complete, not needed or error
//              XMLfile     success         date
// -------------------------------------------------------
// downloaded   data        YES             date returned
// not needed   nil         YES             input date
// error        nil         NO              nil
-(void)didFinishLoadingURL:(NSData *)XMLfile
               withSuccess:(BOOL)success
               findingDate:(NSString *)date;
@end

@interface AtomicGetFileFromRemoteURL : NSObject <NSURLConnectionDelegate>

    -(id)initWithURL:(NSURL *)url
  whenMoreRecentThan:(NSString *)date
  expectingMIMETypes:(NSArray *)MIMEType
        withDelegate:(id <AtomicGetFileFromRemoteURLDelegate>)delegate;

@end
