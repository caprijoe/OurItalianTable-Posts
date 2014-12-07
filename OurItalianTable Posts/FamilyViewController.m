//
//  FamilyViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "FamilyViewController.h"

@implementation FamilyViewController

#pragma mark - View lifecycle methods
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // configure title, logo, etc in this view
    [self configureView];
}

#pragma mark - Private methods

-(void)configureView
{
    // Set the UIView background as lemons
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Lemons.png"]];
    self.view.backgroundColor = background;
    
    // configure logo
    [self.view setOpaque:NO];
    self.logo.image = [UIImage imageNamed:@"ouritaliantable-original-transparent.gif"];
    self.logo.backgroundColor = [UIColor clearColor];
    self.logo.opaque = NO;
    
    [self resetDetailView];
}

#pragma mark - Segue support
-(void)resetDetailView
{
    if (self.splitViewController)
        [self performSegueWithIdentifier:@"Push Family" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id currentDetalVC = self.splitViewController.viewControllers[1];
    if ([currentDetalVC isKindOfClass:[UINavigationController class]])
         currentDetalVC = ((UINavigationController *)currentDetalVC).topViewController;

    if ([segue.identifier isEqualToString:@"Push Family"]) {
        
        id detailVC = segue.destinationViewController;
        if ([detailVC isKindOfClass:[UINavigationController class]])
            detailVC = ((UINavigationController *)detailVC).topViewController;
        
        if ([detailVC isKindOfClass:[PhotoScroller class]]) {
            
            if (![currentDetalVC isKindOfClass:[PhotoScroller class]]) {
                // get rid of left side splitview, segue to photo scroller
                OITTabBarController *splitMasterVC = (OITTabBarController *)self.splitViewController.viewControllers[0];
                [splitMasterVC.masterPopoverController dismissPopoverAnimated:YES];
            }
            
            // transfer the bar button
            [self transferSplitViewBarButtonItemToViewController:detailVC];
        }
    }
}

@end
