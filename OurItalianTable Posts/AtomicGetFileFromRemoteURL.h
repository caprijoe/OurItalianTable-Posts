//
//  AtomicGetFileFromRemoteURL.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"
#define NSURLREQUEST_TIMEOUT_SECONDS                 20.0

@protocol AtomicGetFileFromRemoteURLDelegate <NSObject>;

// call back when file load complete, not needed or error
//              XMLfile     success         date
// -------------------------------------------------------
// downloaded   data        YES             date returned
// not needed   nil         YES             input date
// error        nil         NO              nil

-(void)didFinishLoadingURL:(NSData *)XMLfile withSuccess:(BOOL)success findingDate:(NSString *)date;

@end

@interface AtomicGetFileFromRemoteURL : NSObject <NSURLConnectionDelegate>

// all these properties must be set before "startFileDownload" can be called
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *lastUpdateToDBDate;
@property (nonatomic, strong) id<AtomicGetFileFromRemoteURLDelegate> delegate;
@property (nonatomic, strong) NSArray *expectedMIMETypes;

-(id)init;
-(void)startFileDownload;
-(void)prepareToExit;
-(void)exitGetFileWithData:(NSData *)data withSuccess:(BOOL)success withLastUpdateDate:(NSString *)date;


@end
