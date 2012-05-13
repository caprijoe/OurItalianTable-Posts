//
//  OITLaunchViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OITLaunchViewController : UIViewController <UISplitViewControllerDelegate>;

// outlets
@property (nonatomic, strong) IBOutlet UIButton *foodButtonOutlet;                      // for getting the font of 1st button

// rotation support
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;

@end
