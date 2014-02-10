//
//  PostDetailViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/15/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITViewController.h"
#import "GeneralizedPostsTableViewController.h"
#import "Post.h"
#import "Tag.h"

@protocol PostsDetailViewControllerDelegate
-(void)didClickTag:(NSString *)tag;
@end

@interface PostDetailViewController : OITViewController

// delegate to pass along call back from detail controller
@property (nonatomic, weak) id <PostsDetailViewControllerDelegate> delegate;

// public properties
@property (nonatomic,strong) Post *postDetail; // post for which detail will be displayed

// Outlets
@property (weak, nonatomic) IBOutlet UIImageView *authorPicture;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *datePublished;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *tagsText;

// Actions
- (IBAction)doneButton:(id)sender;

@end
