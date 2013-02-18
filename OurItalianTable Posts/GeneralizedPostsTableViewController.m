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
    
    // updates self.geoCoordinates, self.geoList
    [self setupGeoReferenceInfo];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    // set up fetch controller, update context, setup refresh control and set detail split view
    [self resetToAllEntries];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    // save any loaded changes at this point
    [self.appDelegate.parentMOC save:NULL];
    
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
    
    // load icon if needed into DB
    [self populateIconInDBUsing:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.webRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // bring up web view on right with post detail
    [self performSegueWithIdentifier:@"Push Web View" sender:self];
    
    // get rid of left side splitview
    OITTabBarController *topVC = (OITTabBarController *)self.tabBarController;
    [topVC.masterPopoverController dismissPopoverAnimated:YES];
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
    UIBarButtonItem *rootPopoverButtonItem = ((OITTabBarController *)self.tabBarController).rootPopoverButtonItem;
    
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
    UIBarButtonItem *rootPopoverButtonItem = ((OITLaunchViewController *)[self.navigationController viewControllers][0]).rootPopoverButtonItem;
    
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
        [segue.destinationViewController setRootPopoverButtonItem:((OITTabBarController *)self.tabBarController).rootPopoverButtonItem];
    } else if ([segue.identifier isEqualToString:@"Show TOC Picker"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setGeosInUseList:[self.geoList copy]];
        self.categoryPickerSegue = segue;
    } else if ([segue.identifier isEqualToString:@"Reset Splash View"]) {
        [segue.destinationViewController setRootPopoverButtonItem:((OITTabBarController *)self.tabBarController).rootPopoverButtonItem];
    } else if ([segue.identifier isEqualToString:@"Show Region Map"]) {
        [segue.destinationViewController setGeoCoordinates:[self.geoCoordinates copy]];
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setRootPopoverButtonItem:((OITTabBarController *)self.tabBarController).rootPopoverButtonItem];
    }
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

-(void)doneFillingFromRemote:(BOOL)success {
    
    // release remote filler
    self.thisRemoteDatabaseFiller = nil;
    
    if (success) {
        
        // set up a display dateformatter for today's date
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
        [dataFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
        
        // set up to display today's date until refreshed again
        NSString *lastUpdatedString = [NSString stringWithFormat:@"Last udpated on %@", [dataFormatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdatedString];
    }
    
    // stop twirling ball
    [self.refreshControl endRefreshing];
}

-(void)resetToAllEntries {
    
    if ([self isIOS6OrLater])
        self.refreshControl = nil;
    
    // make sure search bar is reset
    [self.searchDisplayController setActive:NO animated:YES];
    
    // reset context label
    [self updateContext:@"Our Italian Table"];
    
    // reset fetch controller
    [self setupFetchedResultsControllerwithSortKey:self.sortKey withSectionKey:self.sectionKey];
    
    // if on an ipad, reset right side too
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self performSegueWithIdentifier:self.rightSideSegueName sender:self];
    
    // reset table view to top (0,0) & reload table
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.tableView reloadData];
    
    // re-setup refresh control
    [self setupRefreshControl];
}

// load up the table thumbnnail, if not cached, cache it

-(void)populateIconInDBUsing:(NSIndexPath *)indexPath {
    
    Post *postRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    // check if icon is in CoreData DB, if so, just return it by reference
    if (!postRecord.postIcon) {
        dispatch_queue_t queue = dispatch_queue_create("get Icon",NULL);
        dispatch_async(queue, ^{
            
            // make sure the URL string is not nil
            if (postRecord.imageURLString) {

                // load data from URL
                NSError *error = Nil;
                NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:postRecord.imageURLString] options:NSDataReadingUncached error:&error];
                
                NSLog(@"got --> %@",postRecord.postName);

                
                // if we got data AND no error, proceed. Else let the placeholder.png remain
                if (data && !error)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // scale the incoming image to the icon size
                        UIImage *iconImage = [self adjustImage:[UIImage imageWithData:data]];
                        
                        // make sure the context still exists (could happen if view disappears), and update icon
                        if (postRecord.managedObjectContext) {
                            postRecord.postIcon = UIImageJPEGRepresentation(iconImage, 1.0);
                            
                            // save any loaded changes at this point
                            [self.appDelegate.parentMOC save:NULL];

                        }
                        
                    });
            }
        });
        dispatch_release(queue);
    }
}

- (UIImage *)adjustImage:(UIImage *)image
{
    if (image.size.width != POST_ICON_HEIGHT && image.size.height != POST_ICON_HEIGHT)
	{
        
        // Get base sizes
        CGSize imageSize = image.size;
        CGFloat sourceImageWidth = imageSize.width;
        CGFloat sourceImageHeight = imageSize.height;
        
        CGSize targetSize = CGSizeMake(POST_ICON_HEIGHT, POST_ICON_HEIGHT);
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        
        // Initialize
        UIImage *newImage = [[UIImage alloc] init];
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        CGPoint thumbnailPoint = CGPointMake(0, 0);
        
        // Execute
        if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
            CGFloat widthFactor = targetWidth / sourceImageWidth;
            CGFloat heightFactor = targetHeight / sourceImageHeight;
            
            if (widthFactor > heightFactor)
                scaleFactor = widthFactor;  // scale to fit height
            else
                scaleFactor = heightFactor; // scale to fit width
            
            scaledWidth = sourceImageWidth * scaleFactor;
            scaledHeight = sourceImageHeight * scaleFactor;
            
            // center the image
            if (widthFactor > heightFactor)
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            else if (widthFactor < heightFactor)
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        
        // do the crop
        UIGraphicsBeginImageContext(targetSize);
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [image drawInRect:thumbnailRect];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if (newImage == nil) NSLog(@"could not scale image");
        
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    else
        return image;
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
    
    if ([self isIOS6OrLater]) {
        // if running on ios6 and above, include Facebook as an option
        // setup refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to refresh"];
        [self.tableView addSubview:self.refreshControl];
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

@end
