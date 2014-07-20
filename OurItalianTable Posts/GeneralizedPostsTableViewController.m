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
@property (nonatomic, strong) NSMutableDictionary *downloadControl;
@property (nonatomic, strong) NSString *contextTitle;
@end

@implementation GeneralizedPostsTableViewController

#pragma mark - Setters/Getters
-(void)setContextTitle:(NSString *)contextTitle
{
    if (contextTitle)                                   // if got an incoming title, use it
        _contextTitle = contextTitle;
    else if (self.selectedRegion)                       // if not, use the selectedRegion if available
        _contextTitle = self.selectedRegion;
    else
        _contextTitle = self.defaultContextTitle;       // if all else fails, use the default
    
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // reset right side, confirm the correct VC is there and reset if needed
    [self resetDetailView];
}

#pragma mark - Control presentation / reset to original state
-(void)resetToAllEntries {
    
    // reset context label
    self.contextTitle = nil;;
    
    // reset fetch controller
    [self setupFetchedResultsControllerWithPredicate:nil];
    
    // if on an ipad, reset right side too
    [self resetDetailView];
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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

-(void)receivedDBOpenedNotification:(NSNotification *)notification
{
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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"postPubDate" ascending:NO]];
    
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
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.appDelegate.parentMOC sectionNameKeyPath:nil cacheName:nil];
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
    [self displayPost];
    
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

#pragma mark - WebViewControllerDelegate method call back
-(void)didClickTag:(NSString *)tag
{
    // setup search predicate
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(ANY whichTags.tagString =[cd] %@)", tag];
    
    // setup new controller, fetch and reload data
    [self setupFetchedResultsControllerWithPredicate:searchPredicate];
    
    // update context at top of view
    self.contextTitle = tag;
    
    // force the root controller on screen (should not be on screen now because last selection was detailed popover)
    // suppress ARC warning about memory leak - not an issue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // pop back to top when tag clicked
    [self.navigationController popToRootViewControllerAnimated:YES];
    
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

#pragma mark - IBActions
- (IBAction)refreshView:(id)sender
{
    [self resetToAllEntries];
}

-(IBAction)showTOC:(id)sender
{
    [self performSegueWithIdentifier:@"Show TOC Picker" sender:self];
}

#pragma mark - Segue support

-(void)displayPost
{
    // assume right side is a WebViewVC inside a NavVC at this point
    
    // if not in a splitVC, push
    if (!self.splitViewController) {
        [self performSegueWithIdentifier:@"Push Web View" sender:self];
    } else {
        UINavigationController *navVC = (UINavigationController *)self.splitViewController.viewControllers[1];
        WebViewController *webVC = (WebViewController *)navVC.topViewController;
        webVC.thisPost = self.postRecord;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        id detailVC = segue.destinationViewController;
        if ([detailVC isKindOfClass:[UINavigationController class]])
            detailVC = ((UINavigationController *)detailVC).topViewController;
        if ([detailVC isKindOfClass:[WebViewController class]]) {
            [detailVC setThisPost:self.postRecord];
            [detailVC setDelegate:self];
            [self transferSplitViewBarButtonItemToViewController:detailVC];
        }
    }
}

@end
