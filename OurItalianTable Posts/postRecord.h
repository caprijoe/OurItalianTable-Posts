/*
 object that holds data for each post  
 */
#import <MapKit/MapKit.h>

@interface PostRecord : NSObject

@property (nonatomic, strong) NSString *postName;
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) UIImage  *postIcon;
@property (nonatomic, strong) NSString *postAuthor;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *postURLString;
@property (nonatomic, strong) NSString *postHTML;
@property (nonatomic, strong) NSDate   *postPubDate;
@property (nonatomic, strong) NSString *postPubDateAsString;
@property (nonatomic, strong) NSMutableArray *postCategories;
@property (nonatomic, strong) NSMutableArray *postTags;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSString * geo;

@end