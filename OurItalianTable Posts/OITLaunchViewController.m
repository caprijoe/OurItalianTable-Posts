//
//  OITLaunchViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//


#import "OITLaunchViewController.h"

@implementation OITLaunchViewController

#pragma mark - Private methods

// reset right side splash screen when left side appears or disappears
-(void)resetDetailPanel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];        
}

#pragma mark - View lifecycle support

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // set delegate for rotation support
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the UIView background as lemons
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Lemons.png"]];
    self.view.backgroundColor = background;
    
    // set a custom title in the launch controller
    // get font etc from first button
    UILabel *OITTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 440.0, 44.0)];
    OITTitleView.font = self.foodButton.titleLabel.font;
    OITTitleView.backgroundColor = [UIColor clearColor];
    OITTitleView.textColor = self.foodButton.currentTitleColor;
    OITTitleView.textAlignment = UITextAlignmentCenter;
    OITTitleView.text = self.navigationItem.title;
    self.navigationItem.titleView = OITTitleView;
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES; 
}

-(void)viewDidAppear:(BOOL)animated {
    [self resetDetailPanel];
}

#pragma mark - Segue support

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Food"]) {
        [segue.destinationViewController setCategory:FOOD_CATEGORY];
        [segue.destinationViewController setFavs:NO];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Wine"]) {
        [segue.destinationViewController setCategory:WINE_CATEGORY];
        [segue.destinationViewController setFavs:NO];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Travel"]) {
        [segue.destinationViewController setCategory:WANDERING_CATEGORY];
        [segue.destinationViewController setFavs:NO];
        
        // get rid of left side splitview, segue to map to navigate
        OITLaunchViewController *topVC = [[self.navigationController viewControllers] objectAtIndex:0];
        [topVC.masterPopoverController dismissPopoverAnimated:YES];
        
    } else if ([segue.identifier isEqualToString:@"Push Favorites"]) {
        [segue.destinationViewController setFavs:YES];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Family"]) {
        
        // get rid of left side splitview, segue to map to navigate
        OITLaunchViewController *topVC = [[self.navigationController viewControllers] objectAtIndex:0];
        [topVC.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willHideViewController:(UIViewController *)aViewController 
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Menu";
    self.rootPopoverButtonItem = barButtonItem;
    self.masterPopoverController = pc;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.rootPopoverButtonItem = nil;
    self.masterPopoverController = nil;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
