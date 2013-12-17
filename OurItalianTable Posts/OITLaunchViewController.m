//
//  OITLaunchViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "OITLaunchViewController.h"

@implementation OITLaunchViewController

#pragma mark - View lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // configure title, logo, etc in this view
    [self configureView];

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    // put the splash screen up in the detail VC
    [self resetDetailPanel];
} 

#pragma mark - Private methods

-(void)configureView {
    
    // Set the UIView background as lemons
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Lemons.png"]];
    self.view.backgroundColor = background;
    
    // configure logo
    [self.view setOpaque:NO];
    self.logo.image = [UIImage imageNamed:@"ouritaliantable-original-transparent.gif"];
    self.logo.backgroundColor = [UIColor clearColor];
    self.logo.opaque = NO;
}

// reset right side splash screen when left side appears or disappears
-(void)resetDetailPanel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
}


#pragma mark - Segue support
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"Push Family"]) {
        
        // get rid of left side splitview, segue to photo scroller
        OITLaunchViewController *topVC = (OITLaunchViewController *)self.splitViewController.viewControllers[0];
//        [topVC.masterPopoverController dismissPopoverAnimated:YES];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];

    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];

    } else if ([segue.identifier isEqualToString:@"Push About"]) {
        // do nothing
    }
}

@end
