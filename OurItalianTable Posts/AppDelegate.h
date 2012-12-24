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

@interface AppDelegate : UIResponder <UIApplicationDelegate, BundleFillDatabaseFromXMLParserDelegate, RemoteFillDatabaseFromXMLParserDelegate>

// public properties
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;

//public shared methods
-(NSString *)fixCategory:(NSString *)category;

-(void)populateIcon:(Post *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath;

@end
