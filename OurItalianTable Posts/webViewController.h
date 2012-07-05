//
//  webViewController.h
//  oitWebViewController
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

// public properties
@property (weak, nonatomic) UIBarButtonItem *rootPopoverButtonItem;         // button for rotation support
@property (weak, nonatomic) PostRecord *postRecord;                         // post to be displayed
@property (nonatomic,weak) id <WebViewControllerDelegate> delegate;         // delegate call back for pressed TAG button
@end
