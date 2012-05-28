//
//  aboutViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 5/5/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface aboutViewController : UIViewController

// outlets
@property (nonatomic, weak) IBOutlet UITextView *txtDisplay;    // box for displaying about text
@property (weak, nonatomic) IBOutlet UILabel *versionBuildDisplay;

// actions
- (IBAction)doneButton:(id)sender;

@end
