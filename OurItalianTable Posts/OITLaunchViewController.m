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

#pragma mark - Private methods

// reset right side splash screen when left side appears or disappears
-(void)resetDetailPanel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];        
}

-(void)configureButtonw:(UIButton *)button withText:(NSString *)title withImage:(UIImage *)image {
    
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
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Palatino" size:24.0 ]];
    [button setTitleColor:[UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    // adjust image
    [button setImage:image forState:UIControlStateNormal];
    
    // adjust spacing between title and image
    CGFloat textWidth = ([title sizeWithFont:[UIFont fontWithName:@"Palatino" size:24.0]]).width;
    CGFloat imageWidth = image.size.width;
    CGFloat edgeSpacing = 15.0;
    CGFloat spacing = (button.frame.size.width - (edgeSpacing*2) - imageWidth - textWidth);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, spacing)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, spacing, 0, 0)];
    
    // bring image to front
    [button bringSubviewToFront:button.imageView];
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
    UILabel *OITTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 440.0, 44.0)];
    OITTitleView.font = [UIFont fontWithName:@"Palatino" size:24.0 ];
    OITTitleView.backgroundColor = [UIColor clearColor];
    OITTitleView.textColor = [UIColor whiteColor];
    OITTitleView.textAlignment = UITextAlignmentCenter;
    OITTitleView.text = self.navigationItem.title;
    self.navigationItem.titleView = OITTitleView;

    // configure buttons
    [self configureButtonw:self.foodButton withText:@"Food" withImage:[UIImage imageNamed:@"48-fork-and-knife.png"]];
    [self configureButtonw:self.wineButton withText:@"Wine" withImage:[UIImage imageNamed:@"273-grapes.png"]];
    [self configureButtonw:self.wanderingsButton withText:@"Wanderings" withImage:[UIImage imageNamed:@"103-map.png"]];
//    [self configureButtonw:self.familyButton withText:@"The Family" withImage:[UIImage imageNamed:@"112-group.png"]];
//    [self configureButtonw:self.infoButton withText:@"Info" withImage:[UIImage imageNamed:@"42-info.png"]];
    [self configureButtonw:self.bookmarksButton withText:@"Bookmarks" withImage:[UIImage imageNamed:@"58-bookmark.png"]];
    
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

- (void)viewDidUnload {
    [self setFamilyButton:nil];
    [self setInfoButton:nil];
    [self setBookmarksButton:nil];
    [super viewDidUnload];
}
@end
