//
//  oitPostsAppDelegate.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 5/13/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "AppDelegate.h"
#import "BundleFillDatabaseFromXMLParser.h"
#import "RemoteFillDatabaseFromXMLParser.h"
#import "ParseWordPressXML.h"

#define COREDB_NAME             @"OITPostsDatabase-V2.0"
#define WORDPRESS_BUNDLE_FILE   @"OITWPExport"
#define WORDPRESS_REMOTE_URL    @"http://www.ouritaliantable.com/OITLatest.xml"

@interface AppDelegate()
@property (nonatomic, strong) UIManagedDocument *postsDatabase;                                   // core DB file
@property (nonatomic, strong) BundleFillDatabaseFromXMLParser *bundleDatabaseFiller;              // filler object for bundle
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *remoteDatabaseFiller;              // filled object for remote
@end

@implementation AppDelegate

#pragma mark - AppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // alloc init core database object
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"documents directory = %@",documentsDirectory);
    NSURL *databaseURL = [documentsDirectory URLByAppendingPathComponent:COREDB_NAME];
    self.postsDatabase = [[UIManagedDocument alloc] initWithFileURL:databaseURL];
    
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

#pragma mark - Private methods

-(void)fillFromBundle {
    
    // set up URL to read XML file in bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:WORDPRESS_BUNDLE_FILE ofType:@"xml"];
    NSURL *bundleUrl = [NSURL fileURLWithPath:path];
    
    // launch filler for bundle
    self.bundleDatabaseFiller = [[BundleFillDatabaseFromXMLParser alloc] initWithURL:bundleUrl intoDatabase:self.postsDatabase withDelegate:self];
}

-(void)fillFromRemote {
    
    // set uo URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    self.remoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL intoDatabase:self.postsDatabase withDelegate:self];
}

-(void)useDocument {
    
    // if database does not exist, fill with fileFromBundle and then fillFromRemote
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.postsDatabase.fileURL path]]) {
        
        // if DB does not exist, create and open
        [self.postsDatabase saveToURL:self.postsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            // if create failed, abort
            NSAssert(success, @"Core Data savetoURL for DB creation failed");
            
            // coreDB opened, now fill from bundle
            [self fillFromBundle];
            
        }];
        
        // if database does exist, just fillFromRemote - will update if remote file date has changed
    } else  if (self.postsDatabase.documentState == UIDocumentStateClosed) {
        
        // if DB exists and is not open, open it
        [self.postsDatabase openWithCompletionHandler:^(BOOL success) {
            
            // if open failed, abort
            NSAssert(success, @"Core Data open failed");
            
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
