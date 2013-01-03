//
//  RemoteFileGetter.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "AtomicGetFileFromRemoteURL.h"

@protocol RemoteFileGetterDelegate <NSObject>;

-(void)didFinishLoadingRemoteFile:(NSData *)XMLfile
                      withSuccess:(BOOL)success
                      findingDate:(NSString *)date;

@end

@interface RemoteFileGetter : NSObject <AtomicGetFileFromRemoteURLDelegate>;

-(id)initWithURL:(NSURL *)url
whenMoreRecentThan:(NSString *)date
    withDelegate:(id <RemoteFileGetterDelegate>)delegate
     giveUpAfter:(NSTimeInterval)seconds;

@end
