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
@property (nonatomic, strong) NSMutableDictionary *downloadControl;
@property (nonatomic, strong) NSString *contextTitle;
@property (nonatomic, strong) UIPopoverController *popover;
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

    // if a region has been set, assume we segued from a tableviewcontroller and set up predicate
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

#pragma mark - Control presentation / reset to original state
-(void)resetToAllEntries {
    
    // reset context label
    self.contextTitle = nil;;
    
    // reset fetch controller
    [self setupFetchedResultsControllerWithPredicate:nil];
    
    // if on an ipad, reset right side if needed
    self.postRecord = nil;
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
    [self resetDetailView];
    // get rid of left side splitview when row is selected (all nil on iPhone)
    OITTabBarController *topVC = (OITTabBarController *)self.tabBarController;
    [topVC.masterPopoverController dismissPopoverAnimated:YES];
    
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
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
    
    // pop back to tableview when tag clicked (iphone in UINavVC)
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    
    // get root view controllers popover button from left side and make it appear
    UIBarButtonItem *rootPopoverButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [rootPopoverButtonItem.target performSelector:rootPopoverButtonItem.action withObject:rootPopoverButtonItem];
#pragma clang diagnostic pop
    
    // reset detailed view controller, if needed
    [self resetDetailView];
}

#pragma mark - TOCViewController unwind
-(IBAction)unwindFromTOC:(UIStoryboardSegue *)segue {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }

    
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

-(IBAction)showTOC:(id)sender
{
    [self performSegueWithIdentifier:@"Show TOC Picker" sender:self];
}

#pragma mark - Segue support
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Push Web View"]) {
        id detailVC = segue.destinationViewController;
        if ([detailVC isKindOfClass:[UINavigationController class]])
            detailVC = ((UINavigationController *)detailVC).topViewController;
        if ([detailVC isKindOfClass:[WebViewController class]]) {
            [(WebViewController *)detailVC setThisPost:self.postRecord];
            [(WebViewController *)detailVC setDelegate:self];
            [self transferSplitViewBarButtonItemToViewController:detailVC];
        }
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
            self.popover = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
}

@end
