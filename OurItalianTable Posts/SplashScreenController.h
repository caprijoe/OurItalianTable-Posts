//
//  SplashScreenController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/1/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "OITTabBarController.h"

@interface SplashScreenController : UIViewController <SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
