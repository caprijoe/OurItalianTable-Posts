//
//  TravelTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/19/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TravelTableViewController.h"
#import "postRecord.h"
#import "webViewController.h"
#import "PostDetailViewController.h"
#import "OITBrain.h"
#import "TOCViewController.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface TravelTableViewController ()
@property (nonatomic, strong) NSMutableArray *regionList;
@property (nonatomic, strong) NSMutableArray *travelEntries;
@property (nonatomic,strong) PostRecord *webRecord;
@property (nonatomic) BOOL inSearchFlag;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic,strong) UIStoryboardSegue *categoryPickerSegue;
@end

@implementation TravelTableViewController
@synthesize regionList = _regionList;
@synthesize travelEntries = _travelEntries;
@synthesize webRecord = _webRecord;
@synthesize filteredListContent = _filteredListContent;
@synthesize inSearchFlag = _inSearchFlag;
@synthesize myBrain = _myBrain;
@synthesize categoryPickerSegue = _categoryPickerSegue;
@synthesize category = _category;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;

#pragma mark - Private methods

-(void)updateContext:(NSString *)topLevel
          withDetail:(NSString *)detail {
    
    NSString *context = [NSString alloc];
    
    if (!detail)
        context = topLevel;
    else 
        context = [NSString stringWithFormat:@"%@ > %@",topLevel, detail];
    
    // construct custom label for context statement
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,250,15)];
    customLabel.text = context;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        customLabel.textColor = [UIColor darkGrayColor];
    else 
        customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor =  [UIColor clearColor];
    customLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    // add it
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc] initWithCustomView:customLabel],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], 
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetToAllEntries:)], nil];
    self.toolbarItems  = toolbarItems;
    self.navigationController.toolbarHidden = NO;    
}

-(void)resetToAllEntries:(id)sender {
    [self viewDidLoad];
    [self.searchDisplayController setActive:NO animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // indicate no in search at the start
    self.inSearchFlag = NO;
    
    // load and sort candidate regions and islands
    NSMutableOrderedSet *candidateRegions = [NSMutableOrderedSet orderedSet];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
    [candidateRegions addObjectsFromArray:[[[NSDictionary alloc] initWithContentsOfFile:filePath] objectForKey:@"Regions of Italy"]];
    [candidateRegions addObjectsFromArray:[[[NSDictionary alloc] initWithContentsOfFile:filePath] objectForKey:@"Islands"]];
    NSArray *workingArray = [[candidateRegions array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
    candidateRegions = [[NSOrderedSet orderedSetWithArray:workingArray] mutableCopy];
    
    
    // alloc and fill in reference arrays
    self.regionList = [[NSMutableArray alloc] initWithCapacity:[candidateRegions count]];
    self.travelEntries = [[NSMutableArray alloc] initWithCapacity:[candidateRegions count]];
    
    for (NSString *candidate in candidateRegions) {
        NSArray *workingArray = [self.myBrain isFav:NO withTag:nil withCategory:self.category withDetailCategory:candidate];
        if ([workingArray count]) {
            [self.regionList addObject:candidate];
            [self.travelEntries addObject:workingArray];
        }
    }
    
    // update context field at bottom of screen
    [self updateContext:self.category withDetail:nil];
    
    self.tableView.rowHeight = CUSTOM_ROW_HIEGHT;
    
    // create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
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
    return [self.regionList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent count];
    } else {
        return [[self.travelEntries objectAtIndex:section] count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.regionList objectAtIndex:section];
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
    PostRecord *postRecord = nil;
    BOOL inSearch = NO;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        inSearch = YES;
        postRecord = [self.filteredListContent objectAtIndex:indexPath.row];
    } else {
        inSearch = NO;
        postRecord = [[self.travelEntries objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];        
    }
    
    
    cell.textLabel.text = postRecord.postName;
    
    [self.myBrain populateIcon:postRecord forCell:cell forTableView:tableView forIndexPath:indexPath];
    return cell;   
} 


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.webRecord = [self.filteredListContent objectAtIndex:indexPath.row];
    } else {                    
        self.webRecord = [[self.travelEntries objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]; 
    }
    
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
} 

#pragma mark - UISearchDelegate

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = CUSTOM_ROW_HIEGHT;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    self.filteredListContent = [self.myBrain searchScope:scope withString:searchString isFavs:NO withCategory:self.category];
    [self updateContext:self.category withDetail:searchString];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    self.filteredListContent = [self.myBrain searchScope:scope withString:[self.searchDisplayController.searchBar text] isFavs:NO withCategory:self.category];
    
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    self.inSearchFlag = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    self.inSearchFlag = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetToAllEntries:self];
}

#pragma mark -
#pragma mark Handle seques

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
        [segue.destinationViewController setPostRecord:self.webRecord];
        [segue.destinationViewController setDelegate:self];
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        [segue.destinationViewController setDelegate:self];
        self.categoryPickerSegue = segue;
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        [segue.destinationViewController setRootPopoverButtonItem:self.rootPopoverButtonItem];
    }
}
@end
