//
//  AboutViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 5/5/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OITViewController.h"

@interface AboutViewController : OITViewController

// outlets
@property (nonatomic, weak) IBOutlet UITextView *txtDisplay;                // box for displaying about text
@property (weak, nonatomic) IBOutlet UILabel *versionBuildDisplay;

@end
