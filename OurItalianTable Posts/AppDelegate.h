//
//  AppDelegate.h
//  oitPosts V2
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "BundleFillDatabaseFromXMLParser.h"
#import "RemoteFillDatabaseFromXMLParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BundleFillDatabaseFromXMLParserDelegate, RemoteFillDatabaseFromXMLParserDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIManagedDocument *postsDatabase;                               // core DB file

-(void)populateIcon:(Post *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath;

@end
