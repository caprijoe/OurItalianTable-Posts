/*
 object that holds data for each post  
 */
#import <MapKit/MapKit.h>

@interface PostRecord : NSObject

@property (nonatomic, strong) NSString *postName;
@property (nonatomic) int64_t postID;
@property (nonatomic, strong) UIImage  *postIcon;
@property (nonatomic, strong) NSString *postAuthor;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *postURLString;
@property (nonatomic, strong) NSString *postHTML;
@property (nonatomic) NSTimeInterval postPubDate;
@property (nonatomic) int64_t postLastUpdate;
@property (nonatomic, strong) NSMutableArray *postCategories;
@property (nonatomic, strong) NSMutableArray *postTags;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end