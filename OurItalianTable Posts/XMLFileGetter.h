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
#import "SSZipArchive.h"

@interface XMLFileGetter : AtomicGetFileFromRemoteURL;

@property (nonatomic) NSTimeInterval seconds;

-(id)init;

@end
