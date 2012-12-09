//
//  ParseWordPressXML.h
//  oitPosts V2
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

@protocol ParseWordPressXMLDelegate
- (void)didFinishParsing;
- (void)parseErrorOccurred:(NSError *)error;
@end

@interface ParseWordPressXML : NSOperation <NSXMLParserDelegate>
- (id)initWithData:(NSData *)data intoDatabase:(UIManagedDocument *)database withDelegate:(id <ParseWordPressXMLDelegate>)theDelegate;
@end


