//
//  OITLaunchViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OITLaunchViewController.h"
#import "postsTableViewController.h"
#import "OITBrain.h"
#import "SplitViewBarButtonItemPresenter.h"

#define FOOD_CATEGORY       @"food"
#define WINE_CATEGORY       @"wine"
#define WANDERING_CATEGORY  @"wanderings"

@interface OITLaunchViewController()
@property (nonatomic,strong) OITBrain *myBrain;             // set brain object pointer when init-ed

@end

@implementation OITLaunchViewController
@synthesize wineButton = _wineButtonOutlet;
@synthesize wanderingsButton = _wanderingsButtonOutlet;
@synthesize bookmarksButton = _bookmarksButtonOutlet;
@synthesize foodButton = _foodButtonOutlet;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize myBrain = _myBrain;

#pragma mark Private methods

-(void)resetDetailPanel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];        
}

#pragma mark - View lifecycle support

-(void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // disable buttons until loading is done
    self.foodButton.enabled = NO;
    self.wineButton.enabled = NO;
    self.wanderingsButton.enabled = NO;
    self.bookmarksButton.enabled = NO;
    
    // alloc the brain, start the loading
    self.myBrain = [[OITBrain alloc] init];
    self.myBrain.delegate = self;
        
    //Set the UIView background as lemons
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Lemons.png"]];
    self.view.backgroundColor = background;
    
    //set a custome title in the launch controller
    //get font etc from first button
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

- (void)viewDidUnload {
    [self setFoodButton:nil];
    [self setWineButton:nil];
    [self setWanderingsButton:nil];
    [self setBookmarksButton:nil];
    [super viewDidUnload];
}

#pragma mark - Segue support

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Food"]) {
        [segue.destinationViewController setMyBrain:self.myBrain];
        [segue.destinationViewController setCategory:FOOD_CATEGORY];
        [segue.destinationViewController setFavs:NO];
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Wine"]) {
        [segue.destinationViewController setMyBrain:self.myBrain];
        [segue.destinationViewController setCategory:WINE_CATEGORY];
        [segue.destinationViewController setFavs:NO];
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Travel"]) {
        [segue.destinationViewController setMyBrain:self.myBrain];
        [segue.destinationViewController setCategory:WANDERING_CATEGORY];
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Favorites"]) {
        [segue.destinationViewController setMyBrain:self.myBrain];
        [segue.destinationViewController setFavs:YES];
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [self resetDetailPanel];
    } else if ([segue.identifier isEqualToString:@"Push Family"]) {
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
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
    barButtonItem.title = @"Main Menu";
    self.rootPopoverButtonItem = barButtonItem;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    self.masterPopoverController = pc;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.rootPopoverButtonItem = nil;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
    self.masterPopoverController = nil;
}

#pragma mark - External delegates

-(void)OITBrainDidFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.foodButton.enabled = YES;
        self.wineButton.enabled = YES;
        self.wanderingsButton.enabled = YES;
        self.bookmarksButton.enabled = YES;
    });
}

@end
