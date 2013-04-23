//
//  GeneralizedPostsTableViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/28/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "GeneralizedPostsTableViewController.h"

#define CUSTOM_ROW_HIEGHT    60.0

@interface GeneralizedPostsTableViewController ();
@property (nonatomic, strong) Post *webRecord;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIStoryboardSegue *categoryPickerSegue;
@property (nonatomic, strong) NSMutableArray *geoList;
@property (nonatomic, strong) NSMutableArray *geoCoordinates;
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, strong) NSString *sectionKey;
@property (nonatomic, strong) NSString *rightSideSegueName;
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *thisRemoteDatabaseFiller;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableDictionary *downloadControl;
@property (nonatomic)         BOOL scrollingAnimationActive;
@property (nonatomic, strong) UIActivityIndicatorView *initialLoadSpinner;
@end

@implementation GeneralizedPostsTableViewController

#pragma mark - Setters/Getters

-(UIActivityIndicatorView *)initialLoadSpinner {
    
    if (!_initialLoadSpinner) {
        _initialLoadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _initialLoadSpinner.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
        _initialLoadSpinner.backgroundColor = [UIColor grayColor];
        _initialLoadSpinner.hidesWhenStopped = YES;
    }

    return _initialLoadSpinner;
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // setup appDelegate for accessing shared properties and methods
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // set up UITableView delegate and source
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // setup fetchcontroller one-time variable inputs
    if (self.favs || [self.category isEqualToString:FOOD_CATEGORY] || [self.category isEqualToString:WINE_CATEGORY]) {
        
        // sort FOOD, WINE and Bookmarked tables by reverse pubdate and don't use sections
        self.sortKey = @"postPubDate";
        self.sectionKey = nil;
        self.rightSideSegueName = @"Reset Splash View";
        
    } else if ([self.category isEqualToString:WANDERING_CATEGORY]) {
        
        // if TRAVEL is selected, sort by the geo name
        self.sortKey = @"geo";
        self.sectionKey = @"geo";
        self.rightSideSegueName = @"Show Region Map";
    }
    
    // init download control dict
    self.downloadControl = [[NSMutableDictionary alloc] init];
    
    // updates self.geoCoordinates, self.geoList
    [self setupGeoReferenceInfo];
    
    // load up the entries
    [self resetToAllEntries];
    self.scrollingAnimationActive = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    // save any loaded changes at this point
    [self.appDelegate.parentMOC save:NULL];
    
}

#pragma mark - Private methods

-(void)setupGeoReferenceInfo {
    // updates self.geoCoordinates, self.geoList
    
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
    if (error) NSLog(@"error at geoReferenceInfo = %@",error);
    
    // Assuming we got at least one, build the list of Annotations
    if (objects == nil) {
        
        // Handle the error.
        NSLog(@"nil array returned at geoReferenceInfo build");
        
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
}

// update context at bottom of tableviewcontroller
-(void)updateContext:(NSString *)detail {
    
    self.contextLabel.text = detail;
    
}

-(void)refreshTable {
    
    // set up URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    self.thisRemoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL usingParentMOC:self.appDelegate.parentMOC withDelegate:self giveUpAfter:20.0];
}

-(void)resetToAllEntries {
    
    // stop the spinning ball in case it's there
    if ([self isIOS6OrLater]) {
        [self.refreshControl endRefreshing];
    }
    
    // make sure search bar is reset
    [self.searchDisplayController setActive:NO animated:YES];
    
    // reset context label
    [self updateContext:@"Our Italian Table"];
    
    // reset fetch controller
    [self setupFetchedResultsControllerwithSortKey:self.sortKey withSectionKey:self.sectionKey];
    
    // if on an ipad, reset right side too
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:self.rightSideSegueName sender:self];
    
    // warn cellforviewatindexpath that a scroll animation is starting
    self.scrollingAnimationActive = YES;
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    // setup the refresh control but only the first time
    [self setupRefreshControl];
}

// load up the table thumbnnail, if not cached, cache it

-(void)populateIconInDBUsing:(NSIndexPath *)indexPath {
    
    Post *postRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // check if icon is in CoreData DB, if so, just return it by reference
    if (!postRecord.postIcon && postRecord.imageURLString) {
        
        IconDownloader *downloader = [[IconDownloader alloc] init];
        downloader.url = [NSURL URLWithString:postRecord.imageURLString];
        downloader.postID = postRecord.postID;
        downloader.delegate = self;
        
        if (downloader) {
            [self.downloadControl setObject:downloader forKey:downloader.postID];
            [downloader startFileDownload];
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Post *thisPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thisPost.postName;
    if (thisPost.postIcon)
        cell.imageView.image = [UIImage imageWithData:thisPost.postIcon];
    else
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
}

-(void)setupRefreshControl {

    // if running on ios6 and above, include refreshControl as an option
    if ([self isIOS6OrLater]) {
        
        // setup refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
        [self setupRefreshControlTitle];
        [self.tableView addSubview:self.refreshControl];
    }
}

-(void)setupRefreshControlTitle {
    
    if ([self isIOS6OrLater]) {
        // if running on ios6 and above, include refreshControl as an option
        
        // get NSUserDefaults object with date of last download file (if present)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastUpdateDateFromDefaults = [defaults stringForKey:LAST_UPDATE_TO_CORE_DB];
        
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
}

-(BOOL)isIOS6OrLater {
    // Make UIRefreshControl conditional on iOS6 and greater
    NSString *reqSysVerForRefresh = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVerForRefresh options:NSNumericSearch] != NSOrderedAscending)
        return YES;
    else
        return NO;
}

-(BOOL)reviseFetchRequestUsing:(NSString *)searchString
{
    
    if (self.favs) {
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((bookmarked == YES) AND ((postHTML contains[cd] %@) OR (ANY whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@))", searchString, searchString, searchString];
    } else {
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((ANY whichCategories.categoryString =[cd] %@) AND ((postHTML contains[cd] %@) OR (ANY whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@)))", self.category, searchString, searchString, searchString];
    }
    
    [[self fetchedResultsController] performFetch:NULL];
    [self.tableView reloadData];
    
    return YES;
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visiblePaths)
    {
        [self populateIconInDBUsing:indexPath];
    }
    
    // indicate animation scrolling is done
    self.scrollingAnimationActive = NO;

}

-(void)showActivityViewer
{
    
    [self.view addSubview:self.initialLoadSpinner];
    [self.initialLoadSpinner startAnimating];
}

-(void)stopActivityViewer {
    
    [self.initialLoadSpinner stopAnimating];
    
}


#pragma mark - Rotation support

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

#pragma mark - Core data helper

-(void)setupFetchedResultsControllerwithSortKey:(NSString *)sortKey
                                 withSectionKey:(NSString *)sectionKey {
    
    // set up initial fetch request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    // if there's a sectionKey, sort ascending
    if (sectionKey)
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];
    else
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO]];
    
    
    // if we're looking at bookmarks, setup the predicate
    request.predicate = self.favs ? [NSPredicate predicateWithFormat:@"bookmarked == %@", @YES] : [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", self.category];
    
    // setup controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.parentMOC sectionNameKeyPath:sectionKey cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    // Perform fetch and reload table
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate method(s)

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = [self.searchDisplayController isActive] ? self.searchDisplayController.searchResultsTableView : self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];;            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.rowHeight = CUSTOM_ROW_HIEGHT;
    
/*    if (section == 0 && [[self.fetchedResultsController sections][section] numberOfObjects] == 0)
        [self showActivityViewer];
    else
        [self stopActivityViewer]; */
    
    return [[self.fetchedResultsController sections][section] numberOfObjects];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
    
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
    [self configureCell:cell atIndexPath:indexPath];
    
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO && !self.scrollingAnimationActive) {
        
        // load icon if needed into DB
        [self populateIconInDBUsing:indexPath];
        
    } else
        NSLog(@"won't load --> %i, dragging = %d, decelerating = %d, scrollingAnimationActive = %d",indexPath.row, self.tableView.dragging, self.tableView.decelerating, self.scrollingAnimationActive);
    
    return cell;
}

#pragma mark - Table view delegate

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

#pragma mark - Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
        
    [self loadImagesForOnscreenRows];
    
}

#pragma mark - UISearchDelegate

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.rowHeight = CUSTOM_ROW_HIEGHT;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    // update context at bottom of pane
    [self updateContext:searchString];
    
    // do the refetch
    return [self reviseFetchRequestUsing:searchString];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self setupFetchedResultsControllerwithSortKey:self.sortKey withSectionKey:self.sectionKey];
    [self resetToAllEntries];
    
}

#pragma mark - External delegates

-(void)didMapClick:(MapViewController *)sender
          geoNamed:(NSString *)region {
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
#pragma clang diagnostic pop
    
    // scroll to correct position of table for region clicked
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.geoList indexOfObject:region]];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // update context field at bottom of screen
    [self updateContext:region];
}

-(void)didClickTag:(NSString *)tag {
    
    // fetch entries with clicked tab
    
    // remembering if we're in bookmarked entries, setup the predicate
    if (self.favs)
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(bookmarked == %@) AND (ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", @YES, self.category, tag];
    else
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) AND (ANY whichTags.tagString =[cd] %@)", self.category, tag];
    
    [[self fetchedResultsController] performFetch:NULL];
    
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

-(void)didFinishLoadingURL:(NSData *)iconData withSuccess:(BOOL)success findingMetadata:(NSString *)postID
{
    if (iconData && success) {
        
        // get rid of the icondownloader
        [self.downloadControl removeObjectForKey:postID];
        
        Post *thisPost = nil;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        request.predicate = [NSPredicate predicateWithFormat:@"postID = %@", [NSNumber numberWithInt:[postID intValue]]];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postID" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
        
        NSError *error = nil;
        NSArray *matches = [self.appDelegate.parentMOC executeFetchRequest:request error:&error];
        
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

#pragma mark - IBActions
- (IBAction)refreshView:(id)sender
{
    
    [self resetToAllEntries];
    
}

#pragma mark - Handle seques

-(id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] || ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

-(void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

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
        [segue.destinationViewController setGeoCoordinates:[self.geoCoordinates copy]];
        [segue.destinationViewController setDelegate:self];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    }
}

@end
