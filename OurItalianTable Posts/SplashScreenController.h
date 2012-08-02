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

// outlets
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;             // toolbar for "bar button dance"

@end
