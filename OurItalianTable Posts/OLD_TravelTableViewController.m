//
//  TravelTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "OLD_TravelTableViewController.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface OLD_TravelTableViewController ()
@property (nonatomic, strong) Post *webRecord;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *geoList;
@property (nonatomic, strong) NSMutableArray *geoCoordinates;
@end

@implementation OLD_TravelTableViewController

#pragma mark - Core data helper

-(void)setupFetchedResultsController {
    
    // set up initial fetch request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"geo" ascending:YES]];
    
    // we are just looking at the travel section which is specified in self.category
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", self.category];
    
    // setup controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.parentMOC sectionNameKeyPath:@"geo" cacheName:nil];
    
    // Perform fetch and reload table
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

#pragma mark - Private methods

-(void)updateContext:(NSString *)topLevel
          withDetail:(NSString *)detail {
    
    NSString *context = [NSString alloc];
    
    if (!detail)
        context = topLevel;
    else 
        context = [NSString stringWithFormat:@"%@ > %@",topLevel, detail];
    
    // construct custom label for context statement
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,250,20)];
    customLabel.text = context;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        customLabel.textColor = [UIColor darkGrayColor];
    else 
        customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor =  [UIColor clearColor];
    customLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    // add it
    NSArray *toolbarItems = @[[[UIBarButtonItem alloc] initWithCustomView:customLabel],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], 
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetToAllEntries:)]];
    self.toolbarItems  = toolbarItems;
    self.navigationController.toolbarHidden = NO;    
}

-(void)resetToAllEntries:(id)sender {
    
    // if iPad, reload map on right side
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Show Region Map" sender:self];
    
    // reset table view to top (0,0)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // update context field at bottom of screen at refresh
    [self updateContext:self.category withDetail:nil];    
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up the appDelegate so we can access the parentMOC and category dictionary
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // get the list of DISTINCT geos in DB
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.appDelegate.parentMOC];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", self.category];
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"geo"];

    // Execute the fetch.
    NSError *error;
    NSArray *objects = [self.appDelegate.parentMOC executeFetchRequest:request error:&error];
    
    // Assuming we got at least one, build the list of Annotations
    if (objects == nil) {
        
        // Handle the error.
        
    } else {
        
        // build the region list and annotations object
        self.geoList = [NSMutableArray arrayWithCapacity:[objects count]];
        self.geoCoordinates = [[NSMutableArray alloc] initWithCapacity:[self.geoList count]];
        
        for (NSDictionary *region in objects) {
            
            // load into region list
            [self.geoList addObject:region[@"geo"]];
            
            // if there is annotation information, load into annotation object list
            NSArray *geoInfo = self.appDelegate.candidateGeos[region[@"geo"]];
            
            if ([geoInfo count] > 2) {
                
                // create an annotation object with the coordinates
                RegionAnnotation *annotationObject = [[RegionAnnotation alloc] init];
                
                annotationObject.regionName = region[@"geo"];
                annotationObject.latitude = [(NSNumber *)[geoInfo objectAtIndex:0] floatValue];
                annotationObject.longitude = [(NSNumber *)[geoInfo objectAtIndex:1] floatValue];
                annotationObject.flagURL = [geoInfo objectAtIndex:2];
                [self.geoCoordinates addObject:annotationObject];
                
            }
        }
    }
    
    // setup fetch controller
    [self setupFetchedResultsController];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Show Region Map" sender:self];
    
    // update context field at bottom of screen
    [self updateContext:self.category withDetail:nil];
    
    // set custom row height
    self.tableView.rowHeight = CUSTOM_ROW_HIEGHT;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // make sure toolbar is displayed
    [self.navigationController setToolbarHidden:NO];
}

- (WebViewController *)splitWebViewController
{
    id hvc = [self.splitViewController.viewControllers lastObject];
    if (![hvc isKindOfClass:[WebViewController class]]) {
        hvc = nil;
    }
    return hvc;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo>sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo>sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Post Description";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.numberOfLines = 3;
    }
	
    // Configure cell
    Post *thisPost = nil;
    thisPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    cell.textLabel.text = thisPost.postName;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate populateIcon:thisPost forCell:cell forTableView:tableView forIndexPath:indexPath];
    
    return cell;
} 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.webRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
    
    // get rid of left side splitview
    OITLaunchViewController *topVC = [self.navigationController viewControllers][0];
    [topVC.masterPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Delegate responders

-(void)didMapClick:(MapViewController *)sender
          geoNamed:(NSString *)region {
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = ((OITLaunchViewController *)[self.navigationController viewControllers][0]).rootPopoverButtonItem;
    
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
#pragma clang diagnostic pop
    
    // scroll to correct position of table for region clicked
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.geoList indexOfObject:region]];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // update context field at bottom of screen
    [self updateContext:self.category withDetail:region];
}

#pragma mark - Handle seques

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
//        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [segue.destinationViewController setThisPost:self.webRecord];
        [segue.destinationViewController setDelegate:Nil];
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        // nothing for this one
    } else if ([segue.identifier isEqualToString:@"Show Region Map"]) {
        [segue.destinationViewController setGeoCoordinates:[self.geoCoordinates copy]];
        [segue.destinationViewController setDelegate:self];
    }
}

@end
