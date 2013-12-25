//
//  OITViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OITViewController : UIViewController

// abstract class that must be overwritten
- (void)preferredContentSizeChanged:(NSNotification *)aNotification;

@end
