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
@property (nonatomic, strong) Post *postRecord;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *thisRemoteDatabaseFiller;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableDictionary *downloadControl;
@property (nonatomic, strong) NSString *contextTitle;
@end

@implementation GeneralizedPostsTableViewController

#pragma mark - Setters/Getters
-(void)setContextTitle:(NSString *)contextTitle
{
    if (contextTitle)
        _contextTitle = contextTitle;
    else if (self.selectedRegion)
        _contextTitle = self.selectedRegion;
    else
        _contextTitle = self.defaultContextTitle;
    
    self.navigationItem.title = [_contextTitle capitalizedString];
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
    
    // init download control dict
    self.downloadControl = [[NSMutableDictionary alloc] init];
    
    // support for change of perferred text font and size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    // if a region has been set, assume we segued from a tabviewcontroller and set up predicate
    if (self.selectedRegion) {
        self.majorPredicate = [NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", [self.appDelegate fixCategory:self.selectedRegion]];
    }
    
    // load up table if MOC available, otherwise setup notification
    if (self.appDelegate.parentMOC) {
        NSLog(@"MOC available, using");
        [self resetToAllEntries];
    } else {
        NSLog(@"MOC NOT available, setting up Notification");
        [self setupDBOpenedNotification];
    }
    
    // set the title
    self.contextTitle = nil;;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // setup the refresh control but only the first time
    [self setupRefreshControl];
    
    [self resetDetailView];
}

#pragma mark - Control presentation / reset to original state

-(void)resetDetailView {
    
    // override as needed
    
}

-(void)resetToAllEntries {
    
    // stop the spinning ball in case it's there
    [self.refreshControl endRefreshing];
    
    // reset context label
    self.contextTitle = nil;;
    
    // reset fetch controller
    [self setupFetchedResultsControllerWithPredicate:nil];
    
    // if on an ipad, reset right side too
    [self resetDetailView];
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Update UITableView when UIRefreshControl pull down
-(void)refreshTable
{
    // set up URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    [self.appDelegate.parentMOC performBlock:^{
        self.thisRemoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL usingParentMOC:self.appDelegate.parentMOC withDelegate:self giveUpAfter:20.0];
    }];
}

-(void)doneFillingFromRemote:(BOOL)success
{
    // release remote filler
    self.thisRemoteDatabaseFiller = nil;
    
    // reset the refresh control and stop spinning
    [self setupRefreshControl];
}

#pragma mark - Icon download support

-(void)populateIconInDBUsing:(NSIndexPath *)indexPath
{
    // get the entry from the DB based on the index path
    Post *postRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // if there's no icon data AND we have a URL, try and get the icon
    if (!postRecord.postIcon && postRecord.imageURLString) {
        
        // create a downloader
        IconDownloader *downloader = [[IconDownloader alloc] initWithURL:[NSURL URLWithString:[postRecord.imageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] withPostID:postRecord.postID withDelegate:self];
        
        // save it away so we can get rid of it later
        if (downloader) {
            [self.downloadControl setObject:downloader forKey:postRecord.postID];
        }
    }
}

// protocol call back from IconDownloader class
-(void)didFinishLoadingIcon:(NSData *)iconData withSuccess:(BOOL)success withPostID:(NSString *)postID
{
    // if we got back data and success flag, update the post
    if (iconData && success) {
        
        // get rid of the icondownloader
        [self.downloadControl removeObjectForKey:postID];
        
        // call Post class method to update icon image
        [Post updatePostwithPostID:postID withIconData:iconData inManagedObjectContext:self.appDelegate.parentMOC];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // set up the cell
    Post *thisPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thisPost.postName;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    // if we have an icon, render it... otherwise use the placeholder
    if (thisPost.postIcon)
        cell.imageView.image = [UIImage imageWithData:thisPost.postIcon];
    else
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
}

#pragma mark - UIRefresh control methods

/* -(UIRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
        
        // temporarily disabled, this UIRefreshControl should not be done in a UITableView
//        UITableViewController *tableViewController = [[UITableViewController alloc] init];
//        tableViewController.tableView = self.tableView;
        
//        tableViewController.refreshControl = _refreshControl;
        
        // temporarily disabled, this UIRefreshControl should not be done in a UITableView
        //        [self.tableView addSubview:_refreshControl];
    }
    return _refreshControl;
} */

-(void)setupRefreshControl
{
    // get NSUserDefaults object with date of last download file (if present)
    NSString *lastUpdateDateFromDefaults = [[SharedUserDefaults sharedSingleton] getObjectWithKey:LAST_UPDATE_TO_CORE_DB];
    
    // contrusct the string to be displayed
    NSString *displayString;
    if (lastUpdateDateFromDefaults)
        displayString = [NSString stringWithFormat:@"Last update on %@",lastUpdateDateFromDefaults];
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

#pragma mark - Handle notification of DB open complete

-(void)setupDBOpenedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDBOpenedNotification:) name:COREDB_OPENED_NOTIFICATION object:nil];
}

-(void)receivedDBOpenedNotification:(NSNotification *)notification {
    
    NSLog(@"got opened notication");
    
    [self resetToAllEntries];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - NSFetchedResultsController setup

-(void)setupFetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    // set up initial fetch request
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    
    // set up sort descriptors from subclass
    request.sortDescriptors = self.sortDescriptors;
    
    // setup the predicate
    NSMutableArray *predicateArray = [NSMutableArray arrayWithCapacity:2];
    
    if (self.majorPredicate)
        [predicateArray addObject:self.majorPredicate];
    
    if (predicate)
        [predicateArray addObject:predicate];
    
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[predicateArray copy]];
    
    // setup controller
    [self.appDelegate.parentMOC performBlockAndWait:^{
                
        self.fetchedResultsController.delegate = self;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.parentMOC sectionNameKeyPath:self.sectionKey cacheName:nil];
    }];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CUSTOM_ROW_HIEGHT;
}

#pragma mark - UITableViewDelegate protocol method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.postRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // bring up web view on right with post detail
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
    
    // get rid of left side splitview
    if (self.splitViewController) {
        OITTabBarController *topVC = (OITTabBarController *)self.tabBarController;
        [topVC.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // reset to original state
    [self resetToAllEntries];
    
    // dismiss keyboard and clear out search bar
    [searchBar resignFirstResponder];
    searchBar.text = nil;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // dismiss keyboard
    [searchBar resignFirstResponder];
    
    // set the context field
    self.contextTitle = searchBar.text;
    
    // setup fetch predicate
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(postHTML contains[cd] %@) OR (ANY whichTags.tagString contains[cd] %@) OR (postName contains[cd] %@)", searchBar.text, searchBar.text, searchBar.text];
    
    // setup NSFetchedResultsController
    [self setupFetchedResultsControllerWithPredicate:searchPredicate];
    
    // clear out search bar
    searchBar.text = nil;
}

#pragma mark - Dynamic type support

- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - External delegates

#pragma mark - MapViewControllerDelegate method call back

-(void)didMapClick:(MapViewController *)sender
     sectionNumber:(NSInteger)section
{
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
    
    // update context field at top of screen
    self.contextTitle = [self.tableView.dataSource tableView:self.tableView titleForHeaderInSection:section];
}

#pragma mark - PostsDetailViewControllerDelegate method call back

-(void)didClickTag:(NSString *)tag
{
    // setup search predicate
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(ANY whichTags.tagString =[cd] %@)", tag];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[self.majorPredicate, searchPredicate]];
    
    // setup new controller, fetch and reload data
    [self setupFetchedResultsControllerWithPredicate:predicate];
    
    // update context at top of view
    self.contextTitle = tag;
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
#pragma clang diagnostic pop
    
    // reset detailed view controller
    if (self.splitViewController)
        [self resetDetailView];
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)unwindFromPostDetail:(UIStoryboardSegue *)segue {
    
    PostDetailViewController *postDetailVC = [segue sourceViewController];
    
    // setup search predicate
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(ANY whichTags.tagString =[cd] %@)", postDetailVC.clickedTag];
    
    // setup new controller, fetch and reload data
    [self setupFetchedResultsControllerWithPredicate:searchPredicate];
    
    // update context at top of view
    self.contextTitle = postDetailVC.clickedTag;
}

#pragma mark - TOCViewController unwind

-(IBAction)unwindFromTOC:(UIStoryboardSegue *)segue {
    
    TOCViewController *TOCvc = [segue sourceViewController];
    
    NSMutableArray *predicateArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    if (TOCvc.pickedPostType) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString =[cd] %@) ", TOCvc.pickedPostType]];
    }
    
    if (TOCvc.pickedGeo) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString contains[cd] %@)",[self.appDelegate fixCategory: TOCvc.pickedGeo]]];        
    }
    
    if (TOCvc.pickedFoodType) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"(ANY whichCategories.categoryString contains[cd] %@)",[self.appDelegate fixCategory: TOCvc.pickedFoodType]]];
    }

    if ([predicateArray count]) {
        
        // setup new controller, fetch and reload data
        [self setupFetchedResultsControllerWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
        
        // update context at top of view
        if (TOCvc.pickedPostType)
            self.contextTitle = TOCvc.pickedPostType;
        else if (TOCvc.pickedGeo)
            self.contextTitle = TOCvc.pickedGeo;
        else if (TOCvc.pickedFoodType)
            self.contextTitle = TOCvc.pickedFoodType;
    }
}

#pragma mark - IBActions

- (IBAction)refreshView:(id)sender
{
    [self resetToAllEntries];
}

-(IBAction)showTOC:(id)sender {
    [self performSegueWithIdentifier:@"Show TOC Picker" sender:self];
}

#pragma mark - Segue support

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        [segue.destinationViewController setThisPost:self.postRecord];
        [segue.destinationViewController setDelegate:self];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        //
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:@"Show Region Map"]) {
        [segue.destinationViewController setDelegate:self];
        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
    }
}

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

@end
