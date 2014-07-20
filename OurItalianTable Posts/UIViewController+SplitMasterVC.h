//
//  UIViewController+SplitMasterVC.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/17/14.
//  Copyright (c) 2014 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SplitViewBarButtonItemPresenter.h"
#import "WebViewController.h"

@interface UIViewController (SplitMasterVC)

-(id)splitViewDetailWithBarButtonItem;
-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController;
-(void)resetDetailView;

@end
