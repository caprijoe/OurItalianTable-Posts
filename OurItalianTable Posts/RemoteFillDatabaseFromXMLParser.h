//
//  FillSermonDatabase.h
//  ASBH
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetFileFromRemoteURL.h"
#import "ParseWordPressXML.h"

@class RemoteFillDatabaseFromXMLParser;

@protocol RemoteFillDatabaseFromXMLParserDelegate <NSObject>;
-(void)doneFillingFromRemote;
@end

@interface RemoteFillDatabaseFromXMLParser : NSObject <GetFileFromRemoteURLDelegate, ParseWordPressXMLDelegate>
-(id)initWithURL:(NSURL *)url intoDatabase:(UIManagedDocument *)database withDelegate:(id <RemoteFillDatabaseFromXMLParserDelegate>)delegate;
@end
