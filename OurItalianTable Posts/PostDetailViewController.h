//
//  PostDetailViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 1/15/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLDPostRecord.h"
@class PostDetailViewController;

@protocol PostsDetailViewControllerDelegate
-(void)postsDetailViewController:(PostDetailViewController *)sender
                        choseTag:(id)tag;
@end

@interface PostDetailViewController : UIViewController

// delegate to pass along call back from detail controller
@property (nonatomic, weak) id <PostsDetailViewControllerDelegate> delegate;

// properties to be set
@property (nonatomic,strong) OLDPostRecord *postDetail; // post for which detail will be displayed

// Outlets
@property (weak, nonatomic) IBOutlet UIImageView *authorPicture;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *datePublished;
@property (weak, nonatomic) IBOutlet UIView *tagsView;

// Actions
- (IBAction)doneButton:(id)sender;


@end
