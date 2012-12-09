//
//  oitPostsAppDelegate.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 5/13/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleFillDatabaseFromXMLParser.h"
#import "RemoteFillDatabaseFromXMLParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BundleFillDatabaseFromXMLParserDelegate, RemoteFillDatabaseFromXMLParserDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
