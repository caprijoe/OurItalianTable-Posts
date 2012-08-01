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
@property (weak,nonatomic) IBOutlet UIButton *foodButton;                      // for getting the font of 1st button
@property (weak,nonatomic) IBOutlet UIButton *wineButton;
@property (weak,nonatomic) IBOutlet UIButton *wanderingsButton;
@property (weak,nonatomic) IBOutlet UIButton *bookmarksButton;

// rotation support
@property (nonatomic,strong) UIBarButtonItem *rootPopoverButtonItem;            // "main menu" button for use by right controllers
@property (nonatomic,strong) UIPopoverController *masterPopoverController;      // left master popover for dismissing by right as needed

@end
