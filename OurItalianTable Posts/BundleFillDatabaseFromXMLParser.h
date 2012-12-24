//
//  BundleFillDatabaseFromXMLParser.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseWordPressXML.h"

@protocol BundleFillDatabaseFromXMLParserDelegate <NSObject>;

-(void)doneFillingFromBundle;

@end

@interface BundleFillDatabaseFromXMLParser : NSObject <ParseWordPressXMLDelegate>

-(id)initWithURL:(NSURL *)url
  usingParentMOC:(NSManagedObjectContext *)parentMOC
    withDelegate:(id <BundleFillDatabaseFromXMLParserDelegate>)delegate;

@end
