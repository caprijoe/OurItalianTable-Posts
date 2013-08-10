//
//  AppDelegate.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BundleFillDatabaseFromXMLParser.h"
#import "RemoteFillDatabaseFromXMLParser.h"
#import "ParseWordPressXML.h"
#import "Post.h"

#define POST_ICON_HEIGHT            48
#define COREDB_NAME                 @"OITPostsDatabase-V2.0"
#define WORDPRESS_BUNDLE_FILE       @"WPExport"
#define COREDB_OPENED_NOTIFICATION  @"OITUIManagedDocumentOpened"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RemoteFillDatabaseFromXMLParserDelegate>

// public properties
@property (nonatomic, strong) UIWindow *window;

// NSManagedObjectContext for core data access
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;

// reference properties
@property (nonatomic, strong) NSDictionary *categoryDictionary;
@property (nonatomic, strong) NSDictionary *candidateGeos;
@property (nonatomic, strong) NSDictionary *candidateGeoSlugs;

//public shared methods
-(NSString *)fixCategory:(NSString *)category;
-(void)configureButton:(UIButton *)button;
-(void)startStopNetworkActivityIndicator:(BOOL)flag;

@end
