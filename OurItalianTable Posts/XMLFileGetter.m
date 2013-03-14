//
//  RemoteFileGetter.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/1/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "XMLFileGetter.h"

@interface XMLFileGetter ()
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *lastUpdateToDBDate;
@property (nonatomic, strong) id<XMLFileGetterDelegate> delegate;
@property (nonatomic) NSTimeInterval seconds;
@property (nonatomic, strong) AtomicGetFileFromRemoteURL *fileGetter;
@property (nonatomic, strong) Reachability *reach;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation XMLFileGetter

#pragma mark - Init method

-(id)initWithURL:(NSURL *)url
whenMoreRecentThan:(NSString *)date
    withDelegate:(id <XMLFileGetterDelegate>)delegate
     giveUpAfter:(NSTimeInterval)seconds {
    
    self = [super init];
    if (self) {
        
        // save ivars for later use
        self.delegate = delegate;
        self.url = url;
        self.lastUpdateToDBDate = date;
        self.seconds = seconds;
        
        // set up Reachability class to help with internet errors        
        self.reach = [Reachability reachabilityWithHostname:[self.url host]];
        
        [self.reach startNotifier];
        
        // kick off download.. might get error and will retry
        [self startFileDownload];
    }
    
    return self;    
}

#pragma mark - Private methods

-(void)startFileDownload {
    
    // launch the filegetter - must be on main thread because it's using NSURLConnection
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fileGetter = [[AtomicGetFileFromRemoteURL alloc] initWithURL:self.url whenMoreRecentThan:self.lastUpdateToDBDate expectingMIMETypes:@[@"application/xml"] withDelegate:self];
    });    
}

-(void)invokeTimeout {
    
    NSLog(@"killed by timer");
    
    // process timeout
    self.reach.reachableBlock = nil;
    
    [self.delegate didFinishLoadingRemoteFile:nil withSuccess:NO findingDate:nil];
    
}

#pragma mark - External delegates

-(void)didFinishLoadingURL:(NSData *)XMLfile withSuccess:(BOOL)success findingDate:(NSString *)date 
{
    
    if (success) {
        
        // turn off Reachability
        self.reach = nil;
        
        // successfully loaded file or discovered remote file was of same date
        [self.delegate didFinishLoadingRemoteFile:XMLfile withSuccess:success findingDate:date];
    
    } else {
        
        // requeue file load when and if internet comes back

        // if seconds passed in, set up a time out
        if (self.seconds)
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.seconds target:self selector:@selector(invokeTimeout) userInfo:nil repeats:NO];
        
        __weak XMLFileGetter *selfInBlock = self;
        
        NSLog(@"waiting for internet connection");
        
        self.reach.reachableBlock = ^(Reachability * reachability)
        {
            [selfInBlock startFileDownload];
        };        
    }
}

@end
