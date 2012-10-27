//
//  webViewController.h
//  oitWebViewController
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "postRecord.h"
#import "SplitViewBarButtonItemPresenter.h"

@class WebViewController;

@protocol WebViewControllerDelegate
-(void)webViewController:(WebViewController *)sender
                chosetag:(id)tag;
@end

@interface WebViewController : UIViewController <SplitViewBarButtonItemPresenter>

// outlets
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UINavigationItem *topNavBar;

// public properties
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;         // button for rotation support
@property (nonatomic, strong) PostRecord *postRecord;                         // post to be displayed
@property (nonatomic, strong) id <WebViewControllerDelegate> delegate;         // delegate call back for pressed TAG button
@end
