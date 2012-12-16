//
//  GetFileFromRemoteURL.m
//  Our Italian Table Posts
//
//  Created by Joseph Becci on 6/23/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#define REMOTE_LAST_MODIFIED_KEY        @"Last-Modified"

#import "GetFileFromRemoteURL.h"

@interface GetFileFromRemoteURL()
@property (nonatomic, strong) NSURLConnection *urlConnection;                   // NSURLConnection - setup in init, delegate is self
@property (nonatomic, strong) NSMutableData *incomingData;                      // stores accumulated data
@property (nonatomic, strong) id<GetFileFromRemoteURLDelegate> delegate;        // call back delegate
@end

@implementation GetFileFromRemoteURL

#pragma mark Public methods

-(id)initWithURL:(NSURL *)url withDelegate:(id<GetFileFromRemoteURLDelegate>)delegate {
    
    // crash if we are not running on the main thread -- should have been called on main thread
    NSAssert([NSThread isMainThread], @"NSURLConnection not running on main thread");
    
    // save delegate for later
    self.delegate = delegate;
    
    // create NSURL connection and then create NSURLConnection -- delegate is self
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // test connection for success
    NSAssert(self.urlConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return self;
}

#pragma mark - Private methods

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No connection to Internet"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}

-(BOOL)continueWithRemoteFillUsingDate:(NSString*)remoteDateString {
    
    // setup date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ssss zzz"];
    
    // set up NSUserDefaults object and get date of last download file if present
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUpdateDateString = [defaults stringForKey:REMOTE_LAST_MODIFIED_KEY];
    
    if (lastUpdateDateString) {
        // got a good string from NSUserDefaults
        
        // convert NSString date to NSTimeInterval
        NSTimeInterval timeIntervalFromDefaults = [[dateFormatter dateFromString:lastUpdateDateString] timeIntervalSinceReferenceDate];
        NSTimeInterval timeIntervalFromRemote = [[dateFormatter dateFromString:remoteDateString] timeIntervalSinceReferenceDate];
        
        if (timeIntervalFromRemote > timeIntervalFromDefaults) {
            // update should occur            
            return YES;
            
        } else {
            // update not needed
            return NO;
        }
    } else {
        // no defaults string found (must be first time), load needed
        return YES;
    }
}

-(void)exitGetFile {
    
    // no need to continue downloading because remote date is not greater than current date
    
    self.urlConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.delegate didFinishLoadingURL:NULL withSuccess:NO];
    
    self.incomingData = nil;
    
}

#pragma mark - NSURLConnection delegate methods

// connection:didReceiveResponse
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // when connection response received, create new empty data property
    self.incomingData = [NSMutableData data];
        
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        NSDictionary *headers = [((NSHTTPURLResponse *)response) allHeaderFields];
        NSLog(@"didReceiveResponse headers = %@",headers);
        
        if ([self continueWithRemoteFillUsingDate:headers[REMOTE_LAST_MODIFIED_KEY]]) {
            
            // update continue with update, tell Remote Filler of new last modified date
            [self.delegate didReturnRemoteFillDate:headers[REMOTE_LAST_MODIFIED_KEY]];
        } else {
            
            // no need to update, exit data load
            [self exitGetFile];
        }
    } 
}

// connection:didReceiveData
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append incoming data
    [self.incomingData appendData:data];
}

// connection:didFailWithError:error
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"No Connection Error"};
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
    
    // release the connection
    self.urlConnection = nil; 
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    
    NSURLRequest *newRequest = request;
    
    if (redirectResponse) {
        
        newRequest = nil;
        [connection cancel];
    }
    return newRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // release URL connection
    self.urlConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    [self.delegate didFinishLoadingURL:self.incomingData withSuccess:YES];
    
    self.incomingData = nil;
}


@end
