//
//  OITLaunchViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralizedPostsTableViewController.h"
#import "OITSplitMasterViewController.h"
#import "OITTabBarController.h"

#define FOOD_CATEGORY       @"food"
#define WINE_CATEGORY       @"wine"
#define WANDERING_CATEGORY  @"wanderings"

@interface OITLaunchViewController : OITSplitMasterViewController;

// outlets
@property (nonatomic,weak) IBOutlet UIImageView *logo;

// rotation support
@property (nonatomic,strong) UIPopoverController *masterPopoverController;      // left master popover for dismissing by right as needed

@end
