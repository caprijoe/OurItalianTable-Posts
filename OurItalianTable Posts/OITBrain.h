//
//  OITBrain.h
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseXML.h"
#import "postRecord.h"

@interface OITBrain : NSObject <ProcessedPostsDelegate>

// Init causes posts to be parsed from input source
// always returns posts in descending order

// returns NSArray of posts matching the tag and category; tag or category = nil means all
-(NSMutableArray *)withTags:(NSString *)tag
      withCategories:(NSString *)category;

// returns NSArray for scope of search with searchText
-(NSMutableArray *)searchScope:(NSString *)scope           // scope must be "All" | "Title" | "Article" | "Tags"
                    withString:(NSString *)searchText
                  withCategory:(NSString *)category;

// returns favorites list
-(NSMutableArray *)getFavorites;

// loads up tableview icon into right cell from 1) memory, 2) disk cache or 3) URL
-(void)populateIcon:(PostRecord *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath;
@end
