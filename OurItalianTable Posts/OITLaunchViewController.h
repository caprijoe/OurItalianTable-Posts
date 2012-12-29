//
//  OITLaunchViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralizedPostsTableViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

#define FOOD_CATEGORY       @"food"
#define WINE_CATEGORY       @"wine"
#define WANDERING_CATEGORY  @"wanderings"

@interface OITLaunchViewController : UIViewController <UISplitViewControllerDelegate>;

// outlets
@property (nonatomic,weak) IBOutlet UIButton *foodButton;                      // for getting the font of 1st button
@property (nonatomic,weak) IBOutlet UIButton *wineButton;
@property (nonatomic,weak) IBOutlet UIButton *wanderingsButton;
@property (nonatomic,weak) IBOutlet UIButton *bookmarksButton;

// rotation support
@property (nonatomic,strong) UIBarButtonItem *rootPopoverButtonItem;            // "main menu" button for use by right controllers
@property (nonatomic,strong) UIPopoverController *masterPopoverController;      // left master popover for dismissing by right as needed

@end
