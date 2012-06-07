//
//  OITBrain.m
//  oitPosts
//
//  Created by Joseph Becci on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OITBrain.h"
#import "ParseXML.h"
#import "postRecord.h"

#define FAVORITES_KEY       @"FAVORITES_KEY"
#define POST_ICON_HEIGHT    48
#define TMP                 NSTemporaryDirectory()

@interface OITBrain()
@property (nonatomic,strong) ParseXML *parseXML;
@property (nonatomic, strong) NSArray *brainEntries;
@end

@implementation OITBrain
@synthesize parseXML = _parseXML;
@synthesize brainEntries = _brainEntries;


#pragma mark -
#pragma mark Initialization methods

-(id)init {
    self.parseXML = [[ParseXML alloc] init];
    [self.parseXML setDelegate:self];
    [self.parseXML startParse];
    
    return self;
}

-(void)finishedLoadingPosts:(NSArray *)posts {
    self.brainEntries = posts;
}

#pragma mark -
#pragma mark Search methods

-(NSMutableArray *)isFavs:(BOOL)fav
                 withTags:(NSString *)tag
           withCategories:(NSString *)category {
    
    NSEnumerator *postRecordReverseObjectEnumerator;
    
    // create reverse enumerator for FOR statement
    if (!fav) {
        postRecordReverseObjectEnumerator = [self.brainEntries reverseObjectEnumerator];
    } else {
        postRecordReverseObjectEnumerator = [[self getFavorites] reverseObjectEnumerator];
    }
    
    // create target
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    
    if ((!tag) && (!category)) {    // if tag AND category are nil   
        for (PostRecord *postReocrd in postRecordReverseObjectEnumerator) 
            [filtered addObject:postReocrd];
    } 
    else if (!tag) {              // if the tag is empty, just search the category
        for (PostRecord *postRecord in postRecordReverseObjectEnumerator)
        {
            if ([postRecord.postCategories containsObject:category])
                [filtered addObject:postRecord];
        } 
    } else if (!category) {         // if the category is empty, just search the tag
        for (PostRecord *postRecord in postRecordReverseObjectEnumerator)
        {
            if ([postRecord.postTags containsObject:tag])
                [filtered addObject:postRecord];
        }         
    } else {                        // if both are NOT empty, search both
        for (PostRecord *postRecord in postRecordReverseObjectEnumerator)
        {
            if ([postRecord.postTags containsObject:tag] && [postRecord.postCategories containsObject:category])
                [filtered addObject:postRecord];
        }  
    }
    return filtered;
}

-(NSArray *)searchScope:(NSString *)scope 
             withString:(NSString *)searchText
                 isFavs:(BOOL)fav
           withCategory:(NSString *)category {
    
    // set objectEmumerator from private methods
    NSEnumerator *objectEnumerator = [[self isFavs:fav withTags:nil withCategories:category] reverseObjectEnumerator];

    // create target
    NSMutableArray *filtered = [[NSMutableArray alloc] init]; 
    
    // create predicates
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF == %@", searchText];
    NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"SELF == %@", searchText];
    
    // loop thru parsed entries in reserve
    for (PostRecord *postRecord in objectEnumerator)
    {        
        if ([scope isEqualToString:@"Title"]) {         // if "Title" button clicked, search postName only
            NSRange searchResult = [postRecord.postName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (searchResult.location != NSNotFound) 
                [filtered addObject:postRecord];
        } else if ([scope isEqualToString:@"Article"]) {// if "Article" button clicked, search entire HTML
            NSRange searchResult = [postRecord.postHTML rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (searchResult.location != NSNotFound) 
                [filtered addObject:postRecord]; 
        } else if ([scope isEqualToString:@"Tags"]) {   // if "Tags" button clicked, search just tags
            NSArray *results = [postRecord.postTags filteredArrayUsingPredicate:tagPredicate];
            if (results.count !=0 )
                [filtered addObject:postRecord]; 
        } else if ([scope isEqualToString:@"All"]) {    // if "All" clicked, search postName, HTML and tags
            NSRange searchResult1 = [postRecord.postName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange searchResult2 = [postRecord.postHTML rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSArray *results = [postRecord.postTags filteredArrayUsingPredicate:allPredicate];
            if ((searchResult1.location != NSNotFound) || (searchResult2.location != NSNotFound) || (results.count != 0))
                [filtered addObject:postRecord];
        }
        
    }
    return filtered;
}

-(NSArray *)getFavorites
{
    NSArray *favoriteEntries = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
    
    // create target
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    for (PostRecord *entry in self.brainEntries)
    {
        if ([favoriteEntries containsObject:entry.postID])
            [filtered addObject:entry];
    }
    
    return filtered;
}

#pragma mark - 
#pragma mark Icon loading support methods

-(NSString *)uniquePath:(NSString *)postID {
    NSString *filename = [postID stringByAppendingString:@".jpg"];
    NSString *path = [TMP stringByAppendingPathComponent:filename];
    return path;
}

-(BOOL)inIconCache:(NSString *)postID {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self uniquePath:postID]])
        return TRUE;
    else
        return FALSE;
}

-(UIImage *)getIconFromCache:(NSString *)postID {
    return [UIImage imageWithContentsOfFile:[self uniquePath:postID]];
}

-(void)cacheIcon:(NSString *)postID
       withImage:(UIImage*)postIcon {
    [UIImageJPEGRepresentation(postIcon, 1.0) writeToFile:[self uniquePath:postID] atomically:YES];
}


- (UIImage *)adjustImage:(UIImage *)image
{
    if (image.size.width != POST_ICON_HEIGHT && image.size.height != POST_ICON_HEIGHT)
	{
        
        // Get base sizes
        CGSize imageSize = image.size;
        CGFloat sourceImageWidth = imageSize.width;
        CGFloat sourceImageHeight = imageSize.height;
        
        CGSize targetSize = CGSizeMake(POST_ICON_HEIGHT, POST_ICON_HEIGHT);
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        
        // Initialize
        UIImage *newImage = [[UIImage alloc] init];
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        CGPoint thumbnailPoint = CGPointMake(0, 0);
        
        // Execute
        if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
            CGFloat widthFactor = targetWidth / sourceImageWidth;
            CGFloat heightFactor = targetHeight / sourceImageHeight;
            
            if (widthFactor > heightFactor)
                scaleFactor = widthFactor;  // scale to fit height
            else 
                scaleFactor = heightFactor; // scale to fit width
            
            scaledWidth = sourceImageWidth * scaleFactor;
            scaledHeight = sourceImageHeight * scaleFactor;
            
            // center the image
            if (widthFactor > heightFactor)
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            else if (widthFactor < heightFactor)
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        
        // do the crop
        UIGraphicsBeginImageContext(targetSize);
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [image drawInRect:thumbnailRect];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if (newImage == nil) NSLog(@"could not scale image");
        
        UIGraphicsEndImageContext();
        
        return newImage;                
    }
    else
        return image;
}

-(void)populateIcon:(PostRecord *)postRecord
            forCell:(UITableViewCell *)cell
       forTableView:(UITableView *)tableView
       forIndexPath:(NSIndexPath *)indexPath {
    
    // get index of tableview entry in memory array, assume its there somewhere since we just loaded it from XML file
    NSUInteger index = [self.brainEntries indexOfObjectIdenticalTo:postRecord];
    
    // check if icon in in memory array
    if ([[self.brainEntries objectAtIndex:index] postIcon]) {
        cell.imageView.image = [[self.brainEntries objectAtIndex:index] postIcon];
        
    // check if icon is in cache, if found populate memory too
    } else if ([self inIconCache:postRecord.postID]) {
        cell.imageView.image = [self getIconFromCache:postRecord.postID];
        PostRecord *post = [self.brainEntries objectAtIndex:index];
        post.postIcon = cell.imageView.image;
        
    // if all else fails, load from internet. if found, load memory and cache too    
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        dispatch_queue_t queue = dispatch_queue_create("get Icon",NULL);
        dispatch_async(queue, ^{
            NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:postRecord.imageURLString]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *correctCell = [tableView cellForRowAtIndexPath:indexPath];
                correctCell.imageView.image = [self adjustImage:[UIImage imageWithData:data]];
                [correctCell setNeedsLayout];
                
                // load into cache
                [self cacheIcon:postRecord.postID withImage:correctCell.imageView.image];
                
                // load into memory array
                PostRecord *post = [self.brainEntries objectAtIndex:index];
                post.postIcon = correctCell.imageView.image;
                
            });
        });
        dispatch_release(queue);
    }
}

@end
