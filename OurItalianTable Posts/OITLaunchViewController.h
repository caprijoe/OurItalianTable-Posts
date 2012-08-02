//
//  OITLaunchViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITBrain.h"

@interface OITLaunchViewController : UIViewController <UISplitViewControllerDelegate, OITBrainFinishedDelegate>;

// outlets
@property (nonatomic,weak) IBOutlet UIButton *foodButton;                      // for getting the font of 1st button
@property (nonatomic,weak) IBOutlet UIButton *wineButton;
@property (nonatomic,weak) IBOutlet UIButton *wanderingsButton;
@property (nonatomic,weak) IBOutlet UIButton *bookmarksButton;

// rotation support
@property (nonatomic,strong) UIBarButtonItem *rootPopoverButtonItem;            // "main menu" button for use by right controllers
@property (nonatomic,strong) UIPopoverController *masterPopoverController;      // left master popover for dismissing by right as needed

@end
