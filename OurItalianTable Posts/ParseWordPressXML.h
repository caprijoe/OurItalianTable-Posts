//
//  ParseWordPressXML.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "WordPressXMLTags.h"

@protocol ParseWordPressXMLDelegate

- (void)didFinishParsing;
- (void)parseErrorOccurred:(NSError *)error;

@end

@interface ParseWordPressXML : NSOperation <NSXMLParserDelegate>

- (id)initWithData:(NSData *)data
    usingParentMOC:(NSManagedObjectContext *)parentMOC
      withDelegate:(id <ParseWordPressXMLDelegate>)theDelegate;

@end


