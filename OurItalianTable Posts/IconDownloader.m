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
@property (nonatomic, strong) AtomicGetFileFromRemoteURL *iconGetter;
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic) int numberOfAttempts;
@end

@implementation IconDownloader

#pragma mark - Init method

-(id)init
{
    self= [super init];
    if (self) {
        self.iconGetter.expectedMIMETypes = @[@"image/jpeg", @"image/png"];
        self.numberOfAttempts = 0;
    }
    
    return self;
}

-(void)startFileDownload
{
    
    // edit image URL to get path thumbnail instead, if available
    // -- delete and existing dimension
    // -- -150x150 to the primary URL
    
    self.originalURL = self.url;
    
    self.url = [self modifyURLToThumbnailFile:self.originalURL];
    
    // try first with altereded ULR string to get thumbnail
    [super startFileDownload];
}

#pragma mark - External Delegate

-(void)exitGetFileWithData:(NSData *)iconFile withSuccess:(BOOL)success withLastUpdateDate:(NSString *)date
{
    UIImage *newImage;
    
    if (iconFile && success)
    {
        newImage = [self createAndAdjustImage:iconFile];
        self.iconGetter = nil;
        
        NSData *iconData;
            iconData = UIImageJPEGRepresentation(newImage, 1.0);
                
        [self.delegate didFinishLoadingURL:iconData withSuccess:YES findingMetadata:self.postID];
        
    } else if (self.numberOfAttempts == 1) {
        
        // could not get thumbnail file, now try with original URL
        self.iconGetter.url = self.originalURL;
        
        [self.iconGetter startFileDownload];
                
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
