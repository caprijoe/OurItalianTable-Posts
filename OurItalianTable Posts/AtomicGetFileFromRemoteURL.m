//
//  AtomicGetFileFromRemoteURL.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "AtomicGetFileFromRemoteURL.h"

@interface AtomicGetFileFromRemoteURL ()
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *incomingData;
@end

@implementation AtomicGetFileFromRemoteURL

#pragma mark - Init method

-(id)init
{
    
    self = [super init];
    if (self) {
        // init stuff
    }
    
    return self;
    
}

-(void)startFileDownload {
        
    // launch the filegetter - must be on main thread because it's using NSURLConnection
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // crash if we are not running on the main thread -- should have been called on main thread
        NSAssert([NSThread isMainThread], @"NSURLConnection not running on main thread");
        
        // create NSURL connection and then create NSURLConnection -- delegate is self
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:NSURLREQUEST_TIMEOUT_SECONDS];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        // test connection for success
        NSAssert(self.urlConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
}

#pragma mark - NSURLConnection delegate methods

// connection:didReceiveResponse
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    // when connection response received, create new empty data property
    self.incomingData = [NSMutableData data];
    
    NSLog(@"mime => %@",[response MIMEType]);
    
    if (![self.expectedMIMETypes containsObject:[response MIMEType]]) {
        
        [self exitGetFileWithData:nil withSuccess:NO withLastUpdateDate:nil];
        
    } else if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *headers = [((NSHTTPURLResponse *)response) allHeaderFields];
        
        if ([self continueWithRemoteFillUsingDate:headers[REMOTE_LAST_MODIFIED_KEY]]) {
            
            // continue with update, record remote date for passing back with delegate
            self.lastUpdateToDBDate = headers[REMOTE_LAST_MODIFIED_KEY];
            
        } else {
            
            // no need to update, exit data load
            [self exitGetFileWithData:nil withSuccess:YES withLastUpdateDate:self.lastUpdateToDBDate];
            
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

// connection:willSendRequest:redirectResponse
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    
    NSURLRequest *newRequest = request;
    
    if (redirectResponse) {
        
        newRequest = nil;
        [connection cancel];
    }
    return newRequest;
}

// connectionDidFinishLoading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // successfully completed download, clean up and call back
    [self exitGetFileWithData:self.incomingData withSuccess:YES withLastUpdateDate:self.lastUpdateToDBDate];
}

#pragma mark - Private methods

-(BOOL)continueWithRemoteFillUsingDate:(NSString*)remoteDateString {
    
    // setup date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ssss zzz"];
    
    if (self.lastUpdateToDBDate) {
        // got a good string from NSUserDefaults
        
        // convert NSString date to NSTimeInterval
        NSTimeInterval timeIntervalFromDefaults = [[dateFormatter dateFromString:self.lastUpdateToDBDate] timeIntervalSinceReferenceDate];
        NSTimeInterval timeIntervalFromRemote = [[dateFormatter dateFromString:remoteDateString] timeIntervalSinceReferenceDate];
        
        if (timeIntervalFromRemote > timeIntervalFromDefaults) {
            // update should occur
            NSLog(@"will update 1");
            return YES;
            
        } else {
            // update not needed
            NSLog(@"will NOT update -> %f, %f", timeIntervalFromDefaults, timeIntervalFromRemote);

            return NO;
        }
    } else {
        // no defaults string found (must be first time), load needed
        NSLog(@"will update 2");

        return YES;
    }
}

-(void)prepareToExit
{
    // stop connection
    [self.urlConnection cancel];
    
    // nil out connection to dealloc
    self.urlConnection = nil;
    
    // stop network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // clear out any received date
    self.incomingData = nil;


}
- (void)handleError:(NSError *)error
{
    /*    NSString *errorMessage = [error localizedDescription];
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot update app because there is no Internet connection. Click OK to continue."
     message:errorMessage
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alertView show]; */
    
    NSLog(@"HTTP error = %@",[error localizedDescription]);
    
    [self exitGetFileWithData:nil withSuccess:NO withLastUpdateDate:nil];
    
}

-(void)exitGetFileWithData:(NSData *)data
               withSuccess:(BOOL)success
        withLastUpdateDate:(NSString *)date {
    
    [self prepareToExit];
    
    // call back and tell caller were done
    [self.delegate didFinishLoadingURL:data withSuccess:success findingMetadata:date];
    
}

@end
