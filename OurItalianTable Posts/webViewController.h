//
//  webViewController.h
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
#import "Post.h"

@protocol WebViewControllerDelegate
-(void)didClickTag:(NSString *)tag;
@end

@interface WebViewController : UIViewController <SplitViewBarButtonItemPresenter>

// outlets
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;

// public properties
@property (nonatomic, strong) Post *thisPost;                                   // post to be displayed
@property (nonatomic, strong) id <WebViewControllerDelegate> delegate;          // delegate call back for TAG button

@end
