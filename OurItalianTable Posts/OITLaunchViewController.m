//
//  OITLaunchViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
    
    // configure custome buttons
    [self configureButtons];
    
    // put the splash screen up in the detail VC
    [self resetDetailPanel];
} 


#pragma mark - Private methods

-(void)configureView {
    
    // Set the UIView background as lemons
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Lemons.png"]];
    self.view.backgroundColor = background;
    
    // set a custom title in the launch controller
    UILabel *OITTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 440.0, 44.0)];
    OITTitleView.font = [UIFont fontWithName:@"Palatino" size:24.0 ];
    OITTitleView.backgroundColor = [UIColor clearColor];
    OITTitleView.textColor = [UIColor whiteColor];
    OITTitleView.textAlignment = UITextAlignmentCenter;
    OITTitleView.text = @"Our Italian Table";
    self.navigationItem.titleView = OITTitleView;
    
    // configure logo
    [self.view setOpaque:NO];
    self.logo.image = [UIImage imageNamed:@"ouritaliantable-original-transparent.gif"];
    self.logo.backgroundColor = [UIColor clearColor];
    self.logo.opaque = NO;
}

-(void)configureButtons {
    
    for (UIButton *button in self.buttonArray) {
        
        // configure buttons
        [self configureButton:button];
    }

}

// reset right side splash screen when left side appears or disappears
-(void)resetDetailPanel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
}

-(void)configureButton:(UIButton *)button
{
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = button.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:155.0f / 255.0f green:167.0f / 255.0f blue:15.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:238.0f / 255.0f green:240.0f / 255.0f blue:214.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [button.layer insertSublayer:btnGradient atIndex:0];
    
    // adjust corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:5.0f];
    
    // adjust title
    [button.titleLabel setFont:[UIFont fontWithName:@"Palatino" size:24.0 ]];
    [button setTitleColor:[UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1.0] forState:UIControlStateNormal];
        
    // adjust spacing between title and image
    CGFloat textWidth = ([button.titleLabel.text sizeWithFont:[UIFont fontWithName:@"Palatino" size:24.0]]).width;
    CGFloat imageWidth = button.imageView.image.size.width;
    CGFloat edgeSpacing = 15.0;
    CGFloat spacing = (button.bounds.size.width - (edgeSpacing*2) - imageWidth - textWidth);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, spacing)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, spacing, 0, 0)];
    
    // bring image to front
    [button bringSubviewToFront:button.imageView];
}


#pragma mark - Segue support

-(id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] || ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem ];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"Push Family"]) {
        
        // get rid of left side splitview, segue to photo scroller
        OITLaunchViewController *topVC = (OITLaunchViewController *)self.splitViewController.viewControllers[0];
        [topVC.masterPopoverController dismissPopoverAnimated:YES];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];

    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];

    } else if ([segue.identifier isEqualToString:@"Push About"]) {
        // do nothing
    }
}

#pragma mark - Rotation support (iOS 5)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

#pragma mark - IBActions

- (IBAction)buttonClicked:(UIButton *)sender {
    
    // home is first tab so add one
    self.tabBarController.selectedIndex = sender.tag + 1;
}

@end
