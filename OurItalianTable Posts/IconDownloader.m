//
//  IconDownloader.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/17/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#define IMAGE_THUMBNAIL_SIZE @"-150x150"

#import "IconDownloader.h" 


@interface IconDownloader()
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic) int numberOfAttempts;
@end

@implementation IconDownloader
@synthesize url = _url;

#pragma mark - Init method

-(id)init
{
    self= [super init];
    if (self) {
        self.expectedMIMETypes = @[@"image/jpeg", @"image/png", @"image/gif"];
        self.numberOfAttempts = 0;
    }
    
    return self;
}

#pragma mark - Setters

-(void)setUrl:(NSURL *)url
{
    // first time thru (url == nil), save URL and add URL with default thumbnail size
    // after just set URL to incoming parm
    
    if (url) {
        
        if (!_url) {
            
            // edit image URL to get path thumbnail instead, if available
            // -- delete and existing dimension
            // -- -150x150 to the primary URL
            
            self.originalURL = url;
            _url = [self modifyURLToThumbnailFile:self.originalURL];
        } else
            _url = url;
    }
}

-(void)startFileDownload
{
    
    // increment tries
    self.numberOfAttempts++;
    
    // try first with altereded ULR string to get thumbnail
    [super startFileDownload];
}

#pragma mark - External Delegate

-(void)exitGetFileWithData:(NSData *)iconFile withSuccess:(BOOL)success withLastUpdateDate:(NSString *)date
{
    [super prepareToExit];
    
    UIImage *newImage;
    
    if (iconFile && success)
    {
        
        newImage = [self createAndAdjustImage:iconFile];
        
        NSData *iconData;
            iconData = UIImageJPEGRepresentation(newImage, 1.0);
                
        [self.delegate didFinishLoadingURL:iconData withSuccess:YES findingMetadata:[self.postID stringValue]];
        
    } else if (self.numberOfAttempts == 1) {
                
        // could not get thumbnail file, now try with original URL
        self.url = self.originalURL;
        
        [self startFileDownload];
                
    } else if (self.numberOfAttempts == 2) {
                
        // failed on second attempt with original URL, fail out        
        [self.delegate didFinishLoadingURL:nil withSuccess:NO findingMetadata:nil];
        
    }
}

#pragma mark - Private methods
-(UIImage *)createAndAdjustImage:(NSData *)data
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
    
    return newImage;
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
