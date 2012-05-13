/*
     object that holds data for each post
  
  */

#import "postRecord.h"

@implementation PostRecord

@synthesize postName;
@synthesize postID = _postID;
@synthesize postIcon;
@synthesize imageURLString;
@synthesize postAuthor;
@synthesize postURLString;
@synthesize postHTML;
@synthesize postPubDate;
@synthesize postCategories;
@synthesize postTags;
@synthesize coordinate;

@end

