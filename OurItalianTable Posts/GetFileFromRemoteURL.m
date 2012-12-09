//
//  GetFileFromRemoteURL.m
//  ASBHapp
//
//  Created by Joseph Becci on 6/23/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#define LAST_MODIFIED_KEY @"Last-Modified"

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

#pragma mark - NSURLConnection delegate methods

// connection:didReceiveResponse
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // when connection response received, create new empty data property
    self.incomingData = [NSMutableData data];
    
/*    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        NSLog(@"didReceiveResponse statusCode with %i", statusCode);
    } */
    
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        NSDictionary *headers = [((NSHTTPURLResponse *)response) allHeaderFields];
        NSLog(@"didReceiveResponse headers = %@",headers);
        
        [self.delegate didReturnRemoteFillDate:headers[LAST_MODIFIED_KEY]];
        
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
