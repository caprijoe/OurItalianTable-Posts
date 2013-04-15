//
//  RemoteFillDatabaseFromXMLParser.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 9/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseWordPressXML.h"
#import "XMLFileGetter.h"

#define WORDPRESS_REMOTE_URL    @"http://www.ouritaliantable.com/Export-Directory/OITExport-to-iOS-App.zip"
#define LAST_UPDATE_TO_CORE_DB  @"LAST_UPDATE_TO_CORE_DB_DATE"


@protocol RemoteFillDatabaseFromXMLParserDelegate <NSObject>;

-(void)doneFillingFromRemote:(BOOL)success;

@end

@interface RemoteFillDatabaseFromXMLParser : NSObject <XMLFileGetterDelegate, ParseWordPressXMLDelegate>

// zero second means never time out
-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id <RemoteFillDatabaseFromXMLParserDelegate>)delegate
     giveUpAfter:(NSTimeInterval)seconds;

@end
