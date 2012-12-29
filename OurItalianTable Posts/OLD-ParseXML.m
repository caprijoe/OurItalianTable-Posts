//
//  SetupParse.m
//  oitPosts
//
//  Created by Joseph Becci on 1/2/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "ParseXML.h"
#import "ParseOperation.h"

#define WORDPRESS_IMPORT_FILE @"oitWPExport"

@interface ParseXML()
@property (nonatomic,strong) NSURLConnection *postListFeedConnection;   // connection for file read
@property (nonatomic,strong) NSMutableData *postListData;               // blob to hold data as it's read
@property (nonatomic,strong) NSOperationQueue *queue;                   // parse queue
@end

@implementation ParseXML

@synthesize postListFeedConnection = _postListFeedConnection;           
@synthesize postListData = _postListData;                               
@synthesize queue = _queue;                                             
@synthesize delegate = _delegate;

#pragma mark ===== URL READ OPERATIONS =====

// startParse
// 1. Opens connection and kicks off NSConnection for delegates to handle
// 2. Starts network activity indicator spinning
-(void)startParse {
       
    NSString *path = [[NSBundle mainBundle] pathForResource:WORDPRESS_IMPORT_FILE ofType:@"xml"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    
    self.postListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.postListFeedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.postListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.postListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.postListFeedConnection = nil;   // release our connection
}


// connectionDidFinishLoading:connection
// 1. Release connection
// 2. Shut off network activity indicator
// 3. Set up parse queue and launch
// 4. Clear out blob that held read data
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.postListFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
    ParseOperation *parser = [[ParseOperation alloc] initWithData:self.postListData delegate:self];
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
        
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.postListData = nil;
}


#pragma mark ===== PARSING OPERATIONS ======
// didFinish Parsing (delegate of ParseOperation)
// 1. Invoke finishLoadingPosts delegate and pass back parsed data
// 2. Clear out parsing queue
- (void)didFinishParsing:(NSArray *)postList
{

    [[self delegate] finishedLoadingPosts:postList];
    self.queue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)parseErrorOccurred:(NSError *)error
{
 //   [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

@end
