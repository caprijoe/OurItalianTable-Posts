//
//  splashScreen.h
//  oitPosts
//
//  Created by Joseph Becci on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"


@interface SplashScreenController : UIViewController <SplitViewBarButtonItemPresenter>

// properties for rotation / bar button
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) UIBarButtonItem *rootPopoverButtonItem;

@end
