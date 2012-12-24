//
//  RemoteFillDatabaseFromXMLParser.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseWordPressXML.h"
#import "GetFileFromRemoteURL.h"

@protocol RemoteFillDatabaseFromXMLParserDelegate <NSObject>;

-(void)doneFillingFromRemote;

@end

@interface RemoteFillDatabaseFromXMLParser : NSObject <GetFileFromRemoteURLDelegate, ParseWordPressXMLDelegate>

-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id <RemoteFillDatabaseFromXMLParserDelegate>)delegate;

@end
