//
//  OITTabBarController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/2/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface OITTabBarController : UITabBarController <UISplitViewControllerDelegate, UITabBarControllerDelegate>

@property (nonatomic,strong) UIPopoverController *masterPopoverController;      // left master popover for dismissing by right as needed

@end
