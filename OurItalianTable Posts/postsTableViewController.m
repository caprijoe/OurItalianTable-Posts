//
//  postsTableViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 1/7/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import "Post.h"
#import "AppDelegate.h"
#import "OITLaunchViewController.h"
#import "PostsTableViewController.h"
#import "PostDetailViewController.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface PostsTableViewController() <UIActionSheetDelegate>;
@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic, strong) Post *webRecord;
@property (nonatomic, strong) UIStoryboardSegue *categoryPickerSegue;
@property (nonatomic, strong) NSManagedObjectContext *parentMOC;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PostsTableViewController

-(void)setupFetchedResultsController {
    
    // set up initial fetch request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    
    // if we're looking at bookmarks, setup the predicate
    if (self.favs)
        request.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString =[cd] %@) ", [NSNumber numberWithBool:YES], self.category];
    else
        request.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", self.category];
    
    // setup controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.parentMOC sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
        
    // Perform fetch and reload table
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

#pragma mark - Private methods

// update context at bottom of tableviewcontroller
-(void)updateContext:(NSString *)topLevel
          withDetail:(NSString *)detail {
        
    // override toplevel context if we're in favorites
    topLevel = self.favs ? @"favorites" : topLevel;
    
    // if there's a detail context use it, otherwise show none
    NSString *context = detail ? [NSString stringWithFormat:@"%@ > %@",topLevel, detail] : topLevel;
    
    // construct custom label for context statement
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,250,20)];
    customLabel.text = context;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        customLabel.textColor = [UIColor darkGrayColor];
    else 
        customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor =  [UIColor clearColor];
    customLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    // add it to bottom of view
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc] initWithCustomView:customLabel],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], 
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetToAllEntries:)], nil];
    self.toolbarItems  = toolbarItems;
    self.navigationController.toolbarHidden = NO;    
}

-(void)resetToAllEntries:(id)sender {
    
    // make sure search bar is reset
    [self.searchDisplayController setActive:NO animated:YES];
    
    // if this viewcontroller was called from favs button, display "favorites" at bottom, otherwise display selected category (food, wine, wandering)
    self.favs ? [self updateContext:@"favorites" withDetail:nil] : [self updateContext:self.category withDetail:nil];
    
    // reset fetch controller
    [self setupFetchedResultsController];

    // if on an ipad, reset right side too
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:@"Reset Splash View" sender:self];
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // get NSManagedObjectContext from AppDelegate
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.parentMOC = appDelegate.parentMOC;
    
    // setup fetch controller
    [self setupFetchedResultsController];
    
    // if this viewcontroller was called from favs button, display "favorites" at bottom, otherwise display selected category (food, wine, wandering)
    self.favs ? [self updateContext:@"favorites" withDetail:nil] : [self updateContext:self.category withDetail:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // make sure toolbar is displayed
    [self.navigationController setToolbarHidden:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    // save any loaded changes at this point
    [self.parentMOC save:NULL];

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

#pragma mark - NSFetchedResultsControllerDelegate method(s) 
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.rowHeight = CUSTOM_ROW_HIEGHT;
    
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];

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
    
    // grab search scope for passing to fetch controller update method
    NSInteger scope = controller.searchBar.selectedScopeButtonIndex;
    
    // update context at bottom of pane
    [self updateContext:self.category withDetail:searchString];
    
    // do the refetch
    return [self reviseFetchRequestUsing:searchString searchScope:scope];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    // grab the search string for passing to fetch controller update method
    NSString *searchString = controller.searchBar.text;
    
    // do the refetch
    return [self reviseFetchRequestUsing:searchString searchScope:searchOption];
}

// private method used by UISearchDisplayDelegate
-(BOOL)reviseFetchRequestUsing:(NSString *)searchString searchScope:(NSInteger)searchOption {
        
    if ([searchString length]) {
        switch (searchOption) {
                
            // "All" option
            case 0:
                self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND ((postHTML contains[cd] %@) OR (whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@))",self.category, searchString, searchString, searchString];
                break;
            
            // "Article" option
            case 1:
                self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (postHTML contains[cd] %@)",self.category, searchString];
                break;
            
            // "Tags" option
            case 2:
                self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (whichTags.tagString contains[cd] %@)",self.category, searchString];
                break;
            
            // "Title" option
            case 3:
                self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (postName contains[cd] %@)",self.category, searchString];
                break;
                
            default:
                break;
        }
    }
    
    [[self fetchedResultsController] performFetch:NULL];
    [self.tableView reloadData];
    
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setupFetchedResultsController];
    [self resetToAllEntries:self];
}

#pragma mark - External delegates

-(void)didClickTag:(NSString *)tag {
    
    // fetch entries with clicked tab
    
    // remembering if we're in bookmarked entries, setup the predicate
    if (self.favs)
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", [NSNumber numberWithBool:YES], self.category, tag];
    else
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", self.category, tag];
    
    [[self fetchedResultsController] performFetch:NULL];
    
    // update context at bottom of view
    [self updateContext:self.category withDetail:tag];
     
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = ((OITLaunchViewController *)[[self.navigationController viewControllers] objectAtIndex:0]).rootPopoverButtonItem;
    
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
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

-(void)didPickUsingCategory:(NSString *)category detailCategory:(NSString *)detailCategory
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[(UIStoryboardPopoverSegue*)self.categoryPickerSegue popoverController] dismissPopoverAnimated:YES];
    else    
        [self.categoryPickerSegue.destinationViewController dismissModalViewControllerAnimated:YES];
    
    // remembering if we're in bookmarked entries, setup the predicate
    if (self.favs)
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString =[cd] %@)", [NSNumber numberWithBool:YES], detailCategory];
    else
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (ANY whichCategories.categoryString =[cd] %@)", self.category, detailCategory];
    
    [[self fetchedResultsController] performFetch:NULL];
    
    // update context at bottom of view
    [self updateContext:self.category withDetail:detailCategory];
    
    // reload tableview
    [self.tableView reloadData];
}

#pragma mark - Handle seques

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        [segue.destinationViewController setThisPost:self.webRecord];
        [segue.destinationViewController setDelegate:self];
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        [segue.destinationViewController setDelegate:self];
        self.categoryPickerSegue = segue;
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        // nothing to set for this one
    }
}

@end


