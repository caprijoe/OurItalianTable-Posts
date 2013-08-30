//
//  AppDelegate.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 11/16/12.
//  Copyright (c) 2012 Joseph Becci. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SharedUserDefaults.h"

@interface AppDelegate()
@property (nonatomic, strong) UIManagedDocument *postsDatabase;                               // core DB file
@property (nonatomic, strong) RemoteFillDatabaseFromXMLParser *remoteDatabaseFiller;          // filled object for remote
@property (nonatomic) int networkActivityCount;

@end

@implementation AppDelegate

#pragma mark - AppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // alloc init core database object
    NSURL *documentsDirectory = [self applicationDocumentsDirectory];
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
    NSLog(@"ouritaliantable will resign.");
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
    NSLog(@"ouritaliantable will become active.");

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"ouritaliantable will terminate.");
}

#pragma mark - Shared methods for use in other classes

// change display category to the one that WordPress knows
-(NSString *)fixCategory:(NSString *)category {
    NSString *lc = [category lowercaseString];
    NSString *noComma = [lc stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *noQuote = [noComma stringByReplacingOccurrencesOfString:@"'" withString:@""];
    NSString *addHyphen = [noQuote stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return addHyphen;
}

// This class does not touch the background color, text color or text font of the original button
-(void)configureButton:(UIButton *)button {
        
    // set background color - override storyboard
    [button setBackgroundColor:[UIColor blackColor]];
    
    // adjust corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:5.0f];
    
    // Draw a custom gradient
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = button.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [buttonLayer addSublayer:shineLayer];
    
}

-(void)startStopNetworkActivityIndicator:(BOOL)flag {
    
    if (flag) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        self.networkActivityCount++;

        
    } else {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.networkActivityCount--;
        
    }
}

#pragma mark - Private methods

-(void)setupReferenceProperties {
    
    // load filepath to bundle CategoryDictionary plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
    
    // fail if can't find file
    NSAssert(filePath, @"Can't find CategoryDictionary plist bundle file");
    
    // load category dictionary for use by other methods
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];

    // grab keys for "regions" and "islands" and add to candidateGeos dictionary
    NSMutableDictionary *mutableCandidateGeos = [NSMutableDictionary dictionary];
    [mutableCandidateGeos addEntriesFromDictionary:self.categoryDictionary[@"Regions"]];
    [mutableCandidateGeos addEntriesFromDictionary:self.categoryDictionary[@"Islands"]];
    
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

-(void)fillFromRemote {
    
    // set up URL to remote file
    NSURL *remoteURL = [NSURL URLWithString:WORDPRESS_REMOTE_URL];
    
    // launch filler for remote
    self.remoteDatabaseFiller = [[RemoteFillDatabaseFromXMLParser alloc] initWithURL:remoteURL usingParentMOC:self.parentMOC withDelegate:self giveUpAfter:0.0];
}

-(void)useDocument {
    
    // if database does not exist, fill with fileFromBundle and then fillFromRemote
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.postsDatabase.fileURL path]]) {
        NSLog(@"DB does not exist... create it..");
        
        // if DB does not exist, create and open
        [self.postsDatabase saveToURL:self.postsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            // if create failed, abort
            NSAssert(success, @"Core Data savetoURL for DB creation failed");
            
            // setup parent MOC with NSMainQueueConcurrencyType
            self.parentMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [self.parentMOC setPersistentStoreCoordinator:[self.postsDatabase.managedObjectContext persistentStoreCoordinator]];
            
            // post notificaiton that DB opened and MOC available
            [[NSNotificationCenter defaultCenter] postNotificationName:COREDB_OPENED_NOTIFICATION object:self];
                        
            [self fillFromRemote];
            
        }];
        
    // if database does exist, just fillFromRemote - will update if remote file date has changed
    } else  if (self.postsDatabase.documentState == UIDocumentStateClosed) {
        
        NSLog(@"DB does exist... open it..");
        
        // if DB exists and is not open, open it
        [self.postsDatabase openWithCompletionHandler:^(BOOL success) {
            NSLog(@"openwithcompletionhandler complete");
            // if open failed, abort
            NSAssert(success, @"Core Data open failed");

            // setup parent MOC with NSMainQueueConcurrencyType
            self.parentMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

            [self.parentMOC setPersistentStoreCoordinator:[self.postsDatabase.managedObjectContext persistentStoreCoordinator]];
            
            // post notificaiton that DB opened and MOC available
            [[NSNotificationCenter defaultCenter] postNotificationName:COREDB_OPENED_NOTIFICATION object:self];
            
            // coreDB opened, assume previously filled from bundle. now fill from remotr
            [self fillFromRemote];

        }];
    } 
}

#pragma mark - External delegates

-(void)doneFillingFromRemote:(BOOL)success {

     self.remoteDatabaseFiller = nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
