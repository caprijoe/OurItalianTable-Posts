//
//  OITBrain.h
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "ParseXML.h"
#import "PostRecord.h"

@protocol OITBrainFinishedDelegate
-(void)OITBrainDidFinish;
@end

@interface OITBrain : NSObject <ProcessedPostsDelegate>

@property (nonatomic, strong) id<OITBrainFinishedDelegate> delegate;

// Init causes posts to be parsed from input source
// always returns posts in descending order

// returns NSArray of posts matching the tag and category; tag or category = nil means all
-(NSMutableArray *)isFav:(BOOL)fav
                 withTag:(NSString *)tag
            withCategory:(NSString *)category
      withDetailCategory:(NSString*)detailCategory;

// returns NSArray for scope of search with searchText
-(NSMutableArray *)searchScope:(NSString *)scope           // scope must be "All" | "Title" | "Article" | "Tags"
                    withString:(NSString *)searchText
                        isFavs:(BOOL)fav
                  withCategory:(NSString *)category;

// returns favorites list
-(NSMutableArray *)getFavorites;

// loads up tableview icon into right cell from 1) memory, 2) disk cache or 3) URL
-(void)populateIcon:(PostRecord *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath;
@end
