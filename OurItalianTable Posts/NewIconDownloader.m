//
//  IconDownloader.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#define IMAGE_THUMBNAIL_SIZE @"-150x150"
#define EXPECTED_MIME_TYPES @[@"image/jpeg", @"image/png", @"image/gif"]

#import "NewIconDownloader.h"

@interface NewIconDownloader()
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, strong) id<IconDownloaderDelegate> delegate;
@property (nonatomic, strong) NSArray *URLArray;
@end

@implementation NewIconDownloader

#pragma mark - Init method

-(id)initWithURL:(NSURL *)url withPostID:(NSNumber *)postID withDelegate:(id<IconDownloaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.originalURL = url;
        self.delegate = delegate;
        self.postID = postID;
        
        [self startFileDownloadUsingURLs:self.URLArray atPosition:0];
    }
    return self;
}

#pragma mark - Setters
-(void)setOriginalURL:(NSURL *)originalURL
{
    // create an array of URLs to try
    if (originalURL) {
        self.URLArray = @[[self modifyURLToThumbnailFile:originalURL], originalURL];
    }
}

-(void)startFileDownloadUsingURLs:(NSArray *)URLArray atPosition:(int)i
{
    // set up session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // execute data task
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URLArray[i] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // if error or wrong kind of file type, recurse and move to next URL in array
        if (!data || error || ![EXPECTED_MIME_TYPES containsObject:[response MIMEType]]) {
            int j = i + 1;
            if ([URLArray count]>j) {
                [self startFileDownloadUsingURLs:self.URLArray atPosition:j];
            }
        // if success, call back using delegate
        } else
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didFinishLoadingURL:[self createAndAdjustImage:data] withSuccess:YES findingMetadata:[self.postID stringValue]];
            });
    }];
    [dataTask resume];
}

#pragma mark - Private methods
-(NSData *)createAndAdjustImage:(NSData *)data
{
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    UIImage *newImage;
    
    if (image.size.width != POST_ICON_HEIGHT && image.size.height != POST_ICON_HEIGHT)
	{
        CGSize itemSize = CGSizeMake(POST_ICON_HEIGHT, POST_ICON_HEIGHT);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    
    return UIImageJPEGRepresentation(newImage, 1.0);
}

-(NSURL *)modifyURLToThumbnailFile:(NSURL *)incomingURL
{
    // edit image URL to get path thumbnail instead, if available
    // -- delete any existing dimension
    // -- -150x150 to the primary URL
    // -- if malformed URL (no extension), just return incoming
    
    NSString *incomingURLString = [incomingURL absoluteString];
    
    NSRange searchRange = [incomingURLString rangeOfString:@"." options:NSBackwardsSearch];
    if (searchRange.location != NSNotFound) {
        
        NSString *primaryURL = [incomingURLString stringByDeletingPathExtension];
        NSString *fileExtension = [incomingURLString pathExtension];
        
        // look for trailing size information -dddxddd[eol]
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(-)(\\d+)(x)(\\d+)$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:primaryURL options:0 range:NSMakeRange(0, [primaryURL length])];
        
        // if trailing file size info found, delete it
        if  (match)
        {
            primaryURL = [primaryURL substringToIndex:match.range.location];
        }
        
        // attach the thumbnail size for WP
        primaryURL = [primaryURL stringByAppendingString:IMAGE_THUMBNAIL_SIZE];
        
        return [NSURL URLWithString:[primaryURL stringByAppendingPathExtension:fileExtension]];
        
    } else {
        
        // no extension, just return incoming
        return incomingURL;
        
    }
}

@end
