//
//  postsTableViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 1/7/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import "PostsTableViewController.h"
#import "postRecord.h"
#import "webViewController.h"
#import "PostDetailViewController.h"
#import "OITBrain.h"
#import "TOCViewController.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface PostsTableViewController() <UIActionSheetDelegate>;
@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic,strong) PostRecord *webRecord;
@property (nonatomic) BOOL inSearchFlag;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic,strong) UIStoryboardSegue *categoryPickerSegue;
@end

@implementation PostsTableViewController
@synthesize entries = _entries;
@synthesize webRecord = _webRecord;
@synthesize filteredListContent = _filteredListContent;
@synthesize inSearchFlag = _inSearchFlag;
@synthesize myBrain = _myBrain;
@synthesize categoryPickerSegue = _categoryPickerSegue;
@synthesize category = _category;
@synthesize favs = _favs;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;

#pragma mark - Private methods

-(void)updateContext:(NSString *)topLevel
          withDetail:(NSString *)detail {
    
    NSString *context = [NSString alloc];
    
    if (self.favs)
        topLevel = @"favorites";
    
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

    self.inSearchFlag = NO;
    
    self.entries = [self.myBrain isFav:self.favs withTag:nil withCategory:self.category withDetailCategory:nil];

    if (self.favs) {
        [self updateContext:@"favorites" withDetail:nil];
    }
    else {
        [self updateContext:self.category withDetail:nil];
    }
    
    self.tableView.rowHeight = CUSTOM_ROW_HIEGHT;
    
    // create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.entries count]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // make sure toolbar is displayed
    [self.navigationController setToolbarHidden:NO];
    
    if (self.favs) {
        self.entries = [self.myBrain getFavorites];
        [self.tableView reloadData];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent count];
    } else {
        return [self.entries count];
    }
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
        postRecord = [self.entries objectAtIndex:indexPath.row];        
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
        self.webRecord = [self.entries objectAtIndex:indexPath.row]; 
    }

    // bring up web view on right with post detail
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
    
    // get rid of left side splitview
    OITLaunchViewController *topVC = [[self.navigationController viewControllers] objectAtIndex:0];
    [topVC.masterPopoverController dismissPopoverAnimated:YES];
} 

#pragma mark - UISearchDelegate

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = CUSTOM_ROW_HIEGHT;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    self.filteredListContent = [self.myBrain searchScope:scope withString:searchString isFavs:self.favs withCategory:self.category];
    [self updateContext:self.category withDetail:searchString];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    self.filteredListContent = [self.myBrain searchScope:scope withString:[self.searchDisplayController.searchBar text] isFavs:self.favs withCategory:self.category];
    
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

#pragma mark - Delegate responders

-(void)webViewController:(WebViewController *)sender chosetag:(id)tag
{
    // reset memory array with only items that match tag selected in details pop up
    [self setEntries:[self.myBrain isFav:self.favs withTag:tag withCategory:self.category withDetailCategory:nil]];
    [self updateContext:self.category withDetail:tag];
     
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.rootPopoverButtonItem.target performSelector:self.rootPopoverButtonItem.action withObject:self.rootPopoverButtonItem];
    #pragma clang diagnostic pop

    // reset detailed view controller with splash screen
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // reload root controller tableview
    [self.tableView reloadData];
}

-(void)TOCViewController:(TOCViewController *)sender
          categoryPicked:(NSString *)masterCategory
    detailCategoryPicked:(NSString *)detailCategory; 
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[(UIStoryboardPopoverSegue*)self.categoryPickerSegue popoverController] dismissPopoverAnimated:YES];
    else    
        [self.categoryPickerSegue.destinationViewController dismissModalViewControllerAnimated:YES];
    self.entries = [self.myBrain isFav:self.favs withTag:nil withCategory:self.category withDetailCategory: detailCategory];
    [self updateContext:self.category withDetail:detailCategory];
    [self.tableView reloadData];
}


#pragma mark - Handle seques

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


