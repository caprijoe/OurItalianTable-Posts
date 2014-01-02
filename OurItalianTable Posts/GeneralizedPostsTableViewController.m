//
//  GeneralizedPostsTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/28/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "Post.h"
#import "OITTabBarController.h"
#import "AppDelegate.h"
#import "OITLaunchViewController.h"
#import "GeneralizedPostsTableViewController.h"
#import "SharedUserDefaults.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface GeneralizedPostsTableViewController ();
@property (nonatomic, strong) Post *webRecord;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIStoryboardSegue *categoryPickerSegue;
@property (nonatomic, strong) NSMutableArray *geoList;
@property (nonatomic, strong) NSMutableArray *geoCoordinates;
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *thisRemoteDatabaseFiller;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableDictionary *downloadControl;
@end

@implementation GeneralizedPostsTableViewController

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // setup appDelegate for accessing shared properties and methods
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // set up UITableView delegate and source
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // init download control dict
    self.downloadControl = [[NSMutableDictionary alloc] init];
    
    // setup the refresh control but only the first time
    [self setupRefreshControl];
    
    // load up table if MOC available, otherwise setup notification
    if (self.appDelegate.parentMOC) {
        NSLog(@"MOC available, using");
        [self resetToAllEntries];
    } else {
        NSLog(@"MOC NOT available, setting up Notification");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDBOpenedNotification:) name:COREDB_OPENED_NOTIFICATION object:nil];
    }
   
    // setup the custom row height
    self.tableView.rowHeight = CUSTOM_ROW_HIEGHT;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // save any loaded changes at this point
    [self.appDelegate.parentMOC performBlockAndWait:^{
        [self.appDelegate.parentMOC save:NULL];
    }];
    
}

#pragma mark - Private methods

// update context at bottom of tableviewcontroller
-(void)updateContext:(NSString *)detail {
    
    self.contextLabel.text = detail;
    
}

-(void)refreshTable {
    
    // set up URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    [self.appDelegate.parentMOC performBlock:^{
        self.thisRemoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL usingParentMOC:self.appDelegate.parentMOC withDelegate:self giveUpAfter:20.0];
    }];
}

-(void)resetRightSide {
    
    // if on an ipad, reset right side too
    if (self.splitViewController)
        [self performSegueWithIdentifier:self.rightSideSegueName sender:self];
    
}

-(void)resetToAllEntries {
    
    // stop the spinning ball in case it's there
    [self.refreshControl endRefreshing];
    
    // reset context label
    [self updateContext:@"Our Italian Table"];
    
    // reset fetch controller
    NSPredicate *predicate = self.favs ? [NSPredicate predicateWithFormat:@"bookmarked == %@", @YES] : [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", self.category];
    [self setupFetchedResultsControllerwithSortKey:self.sortKey
                                    withSectionKey:self.sectionKey
                                     withPredicate:predicate];
    
    // if on an ipad, reset right side too
    [self resetRightSide];
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
}

#pragma mark - Icon download support
-(void)populateIconInDBUsing:(NSIndexPath *)indexPath {
    
    Post *postRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // check if icon is in CoreData DB, if so, just return it by reference
    if (!postRecord.postIcon && postRecord.imageURLString) {
        
        NewIconDownloader *downloader = [[NewIconDownloader alloc] initWithURL:[NSURL URLWithString:[postRecord.imageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] withPostID:postRecord.postID withDelegate:self];
        
        if (downloader) {
            [self.downloadControl setObject:downloader forKey:postRecord.postID];
        }
    }
}
-(void)didFinishLoadingIcon:(NSData *)iconData withSuccess:(BOOL)success withPostID:(NSString *)postID
{
    if (iconData && success) {
        
        // get rid of the icondownloader
        [self.downloadControl removeObjectForKey:postID];
        
        Post *thisPost = nil;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        request.predicate = [NSPredicate predicateWithFormat:@"postID = %@", [NSNumber numberWithInt:[postID intValue]]];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postID" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
        
        __block NSError *error = nil;
        __block NSArray *matches;
        
        [self.appDelegate.parentMOC performBlockAndWait:^{
            matches = [self.appDelegate.parentMOC executeFetchRequest:request error:&error];
        }];
        
        if (!matches || ([matches count] > 1)) {
            
            // handle error - nil matchs or more than 1
            NSLog(@"error -- more than one match of Post returned from database");
            
        } else if ([matches count] == 0) {
            
            // no match found, insert
            NSLog(@"error -- no post entry found");
            
        } else {
            
            // match found, update
            thisPost = [matches lastObject];
            thisPost.postIcon = iconData;
            
            // save any loaded changes at this point
            [thisPost.managedObjectContext save:NULL];    // save any loaded changes at this point
            
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Post *thisPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thisPost.postName;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    if (thisPost.postIcon)
        cell.imageView.image = [UIImage imageWithData:thisPost.postIcon];
    else
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
}

#pragma mark - UIRefresh control methods

-(UIRefreshControl *)refreshControl {
    
    if (!_refreshControl)
        _refreshControl = [[UIRefreshControl alloc] init];
    return _refreshControl;
}

-(void)setupRefreshControl
{
    // setup refresh control
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self setupRefreshControlTitle];
    [self.tableView addSubview:self.refreshControl];
}

-(void)setupRefreshControlTitle
{
    // get NSUserDefaults object with date of last download file (if present)
    NSString *lastUpdateDateFromDefaults = [[SharedUserDefaults sharedSingleton] getObjectWithKey:LAST_UPDATE_TO_CORE_DB];
    
    // contrusct the string to be displayed
    NSString *displayString;
    if (lastUpdateDateFromDefaults)
        displayString = [NSString stringWithFormat:@"Last update on %@",lastUpdateDateFromDefaults]    ;
    else
        displayString = @"Pull down to refresh";
    
    //update UIRefreshControl message
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:displayString];
    
    // stop twirling ball
    [self.refreshControl endRefreshing];
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)
// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visiblePaths)
    {
        [self populateIconInDBUsing:indexPath];
    }
}

-(void)receivedDBOpenedNotification:(NSNotification *)notification {
    
    NSLog(@"got opened notication");
    
    [self resetToAllEntries];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Core data helper
-(void)setupFetchedResultsControllerwithSortKey:(NSString *)sortKey
                                 withSectionKey:(NSString *)sectionKey
                                  withPredicate:(NSPredicate *)predicate
{
    // set up initial fetch request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    // if there's a sectionKey, sort ascending
    if (sectionKey)
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];
    else
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO]];
    
    
    // if we're looking at bookmarks, setup the predicate
    request.predicate = predicate;
    
    // setup controller
    __block NSError *error = nil;
    
    [self.appDelegate.parentMOC performBlockAndWait:^{
                
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.parentMOC sectionNameKeyPath:sectionKey cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
        // Perform fetch and reload table
        [self.fetchedResultsController performFetch:&error];
        
    }];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource protocol method

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
    [self configureCell:cell atIndexPath:indexPath];
    
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
        
        // load icon if needed into DB
        [self populateIconInDBUsing:indexPath];
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate protocol method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.webRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // bring up web view on right with post detail
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
    
    // get rid of left side splitview
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        OITTabBarController *topVC = (OITTabBarController *)self.tabBarController;
        [topVC.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    // reset to original state
    [self resetToAllEntries];
    
    // dismiss keyboard and clear out search bar
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // dismiss keyboard
    [searchBar resignFirstResponder];
    
    // hack to leave cancel button enabled
    for (id subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:YES];
        }
    }
    
    // set the context field
    [self updateContext:searchBar.text];
    
    // refetch based on search string
    NSPredicate *predicate;
    if (self.favs)
        predicate = [NSPredicate predicateWithFormat:@"((bookmarked == YES) AND ((postHTML contains[cd] %@) OR (ANY whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@))", searchBar.text, searchBar.text, searchBar.text];
    else
        predicate = [NSPredicate predicateWithFormat:@"((ANY whichCategories.categoryString =[cd] %@) AND ((postHTML contains[cd] %@) OR (ANY whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@)))", self.category, searchBar.text, searchBar.text, searchBar.text];
    
    [self setupFetchedResultsControllerwithSortKey:self.sortKey
                                    withSectionKey:self.sectionKey
                                     withPredicate:predicate];
    
    // clear out search bar
    searchBar.text = nil;
}

#pragma mark - Dynamic type support
- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - External delegates

-(void)didMapClick:(MapViewController *)sender
     sectionNumber:(NSInteger)section {
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
#pragma clang diagnostic pop
    
    // scroll to correct position of table for region clicked
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // update context field at bottom of screen
    [self updateContext:[self.tableView.dataSource tableView:self.tableView titleForHeaderInSection:section]];
}

-(void)didClickTag:(NSString *)tag {
    
    // fetch entries with clicked tab
    
    // remembering if we're in bookmarked entries, setup the predicate
    if (self.favs)
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", @YES, self.category, tag];
    else
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", self.category, tag];
    
    NSError *error;
    [[self fetchedResultsController] performFetch:&error];
    
    // update context at bottom of view
    [self updateContext:tag];
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    
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
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString contains[cd] %@)", @YES, [self.appDelegate fixCategory: detailCategory]];
    else
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (ANY whichCategories.categoryString contains[cd] %@)", self.category, [self.appDelegate fixCategory: detailCategory]];
    
    [[self fetchedResultsController] performFetch:NULL];
    
    // update context at bottom of view
    [self updateContext:detailCategory];
    
    // reload tableview
    [self.tableView reloadData];
}

-(void)doneFillingFromRemote:(BOOL)success {
    
    // release remote filler
    self.thisRemoteDatabaseFiller = nil;
    
    // reset the refresh control and stop spinning
    [self setupRefreshControlTitle];
}


#pragma mark - IBActions
- (IBAction)refreshView:(id)sender
{
    [self resetToAllEntries];
}

#pragma mark - Handle seques
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        [segue.destinationViewController setThisPost:self.webRecord];
        [segue.destinationViewController setDelegate:self];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        [segue.destinationViewController setDelegate:self];
        self.categoryPickerSegue = segue;
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:@"Show Region Map"]) {
        [segue.destinationViewController setDelegate:self];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    }
}

@end
