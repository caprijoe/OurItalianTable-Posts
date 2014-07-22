//
//  WebViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#import "SplitViewBarButtonItemPresenter.h"
#import "PostDetailViewController.h"

@protocol WebViewControllerDelegate <NSObject>
-(void)didClickTag:(NSString *)string;
@end

@interface WebViewController : UIViewController <PostsDetailViewControllerDelegate, SplitViewBarButtonItemPresenter>

// public delegate
@property (nonatomic, weak) id<WebViewControllerDelegate> delegate;

// outlets
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *infoButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *mapButton;

// public properties
@property (nonatomic, strong) Post *thisPost;                                   // post to be displayed

@end