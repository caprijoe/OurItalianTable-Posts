//
//  BundleFillDatabaseFromXMLParser.h
//  oitPosts V2
//
//  Created by Joseph Becci on 12/1/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseWordPressXML.h"

@class BundleFillDatabaseFromXMLParser;

@protocol BundleFillDatabaseFromXMLParserDelegate <NSObject>;
-(void)doneFillingFromBundle;
@end

@interface BundleFillDatabaseFromXMLParser : NSObject <ParseWordPressXMLDelegate>
-(id)initWithURL:(NSURL *)url intoDatabase:(UIManagedDocument *)database withDelegate:(id <BundleFillDatabaseFromXMLParserDelegate>)delegate;
@end
