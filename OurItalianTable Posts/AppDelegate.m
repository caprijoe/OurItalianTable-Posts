//
//  AppDelegate.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import "AppDelegate.h"

#define POST_ICON_HEIGHT        48
#define COREDB_NAME             @"OITPostsDatabase-V2.0"
#define WORDPRESS_BUNDLE_FILE   @"OITWPExport"
#define WORDPRESS_REMOTE_URL    @"http://www.ouritaliantable.com/OITLatest.xml"

@interface AppDelegate()
@property (nonatomic, strong) UIManagedDocument *postsDatabase;                               // core DB file
@property (nonatomic, strong) BundleFillDatabaseFromXMLParser *bundleDatabaseFiller;              // filler object for bundle
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *remoteDatabaseFiller;              // filled object for remote
@end

@implementation AppDelegate

#pragma mark - AppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // alloc init core database object
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *databaseURL = [documentsDirectory URLByAppendingPathComponent:COREDB_NAME];
    self.postsDatabase = [[UIManagedDocument alloc] initWithFileURL:databaseURL];
    
    // setup public reference properties
    [self setupReferenceProperties];
    
    // use doc, create or open depending on current state
    [self useDocument];    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Shared methods for use in other classes

// load up the table thumbnnail, if not cached, cache it
-(void)populateIcon:(Post *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath {
    
    // check if icon is in CoreData DB, if so, just return it by reference
    if (postRecord.postIcon) {
        cell.imageView.image = [UIImage imageWithData:postRecord.postIcon];
        
    // else if not found, load from internet. if can't load, just leave placeholder.png for cell
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        dispatch_queue_t queue = dispatch_queue_create("get Icon",NULL);
        dispatch_async(queue, ^{
            
            // make sure the URL string is not nil
            if (postRecord.imageURLString) {
                
                // load data from URL
                NSError *error = Nil;
                NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:postRecord.imageURLString] options:NSDataReadingUncached error:&error];
                
                // if we got data AND no error, proceed. Else let the placeholder.png remain
                if (data && !error)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // scale the incoming image to the icon size
                        UIImage *iconImage = [self adjustImage:[UIImage imageWithData:data]];
                        
                        // load into correct tableview cell
                        UITableViewCell *correctCell = [tableView cellForRowAtIndexPath:indexPath];
                        correctCell.imageView.image = iconImage;
                        [correctCell setNeedsLayout];
                        
                        // make sure the context still exists (could happen if view disappears), and update icon
                        if (postRecord.managedObjectContext)
                            postRecord.postIcon = UIImageJPEGRepresentation(iconImage, 1.0);
                        
                    });
            }
        });
        dispatch_release(queue);
    }
}

// change display category to the one that WordPress knows
-(NSString *)fixCategory:(NSString *)category {
    NSString *lc = [category lowercaseString];
    NSString *noComma = [lc stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *noQuote = [noComma stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSString *addHyphen = [noQuote stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return addHyphen;
}

#pragma mark - Private methods

-(void)setupReferenceProperties {
    
    // load filepath to bundle plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
    
    // fail if can't find file
    NSAssert(filePath, @"Can't find CategoryDictionary plist bundle file");

    // load and sort (using dictionary) candidate regions and islands
    NSMutableDictionary *mutableCandidateGeos = [NSMutableDictionary dictionary];
    [mutableCandidateGeos addEntriesFromDictionary:[[NSDictionary alloc] initWithContentsOfFile:filePath][@"Regions of Italy"]];
    [mutableCandidateGeos addEntriesFromDictionary:[[NSDictionary alloc] initWithContentsOfFile:filePath][@"Islands"]];
    
    // set up the dictionary for public use
    self.candidateGeos = [mutableCandidateGeos copy];
    
    // set up a reference array for the slugs and cross walk back to original key
    NSMutableDictionary *muteableCandidateGeoSlugs = [[NSMutableDictionary alloc] initWithCapacity:[[self.candidateGeos allKeys] count]];
    
    for (NSString *key in [mutableCandidateGeos allKeys]) {
        muteableCandidateGeoSlugs[[self fixCategory:key]] = key;
    }
    
    // set up the array for public use
    self.candidateGeoSlugs = [muteableCandidateGeoSlugs copy];    
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

-(void)fillFromBundle {
    
    // set up URL to read XML file in bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:WORDPRESS_BUNDLE_FILE ofType:@"xml"];
    
    NSAssert(path, @"Unable to find bundle file");
    
    NSURL *bundleUrl = [NSURL fileURLWithPath:path];
    
    // launch filler for bundle
    self.bundleDatabaseFiller = [[BundleFillDatabaseFromXMLParser alloc] initWithURL:bundleUrl usingParentMOC:self.parentMOC withDelegate:self];
}

-(void)fillFromRemote {
    
    // set up URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    self.remoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL usingParentMOC:self.parentMOC withDelegate:self];
}

-(void)useDocument {
    
    // if database does not exist, fill with fileFromBundle and then fillFromRemote
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.postsDatabase.fileURL path]]) {
        
        // if DB does not exist, create and open
        [self.postsDatabase saveToURL:self.postsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            // if create failed, abort
            NSAssert(success, @"Core Data savetoURL for DB creation failed");
            
            // setup parent MOC with NSMainQueueConcurrencyType
            self.parentMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [self.parentMOC setPersistentStoreCoordinator:[self.postsDatabase.managedObjectContext persistentStoreCoordinator]];
                        
            // coreDB opened, now fill from bundle
            [self fillFromBundle];
            
        }];
        
    // if database does exist, just fillFromRemote - will update if remote file date has changed
    } else  if (self.postsDatabase.documentState == UIDocumentStateClosed) {
        
        // if DB exists and is not open, open it
        [self.postsDatabase openWithCompletionHandler:^(BOOL success) {
            
            // if open failed, abort
            NSAssert(success, @"Core Data open failed");

            // setup parent MOC with NSMainQueueConcurrencyType
            self.parentMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [self.parentMOC setPersistentStoreCoordinator:[self.postsDatabase.managedObjectContext persistentStoreCoordinator]];
            
            // coreDB opened, assume previously filled from bundle. now fill from remotr
            [self fillFromRemote];

        }];
    } 
}

#pragma mark - External delegates

-(void)doneFillingFromBundle {
    self.bundleDatabaseFiller = nil;
    [self fillFromRemote];
}

-(void)doneFillingFromRemote {
     self.remoteDatabaseFiller = nil;
}

@end
