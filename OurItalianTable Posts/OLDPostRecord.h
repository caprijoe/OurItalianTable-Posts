/*
 object that holds data for each post  
 */
#import <MapKit/MapKit.h>

@interface OLDPostRecord : NSObject

@property (nonatomic, strong) NSString *postName;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) UIImage  *postIcon;
@property (nonatomic, strong) NSString *postAuthor;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *postURLString;
@property (nonatomic, strong) NSString *postHTML;
@property (nonatomic, strong) NSString *postPubDate;
@property (nonatomic, strong) NSMutableArray  *postCategories;
@property (nonatomic, strong) NSMutableArray  *postTags;
@property (nonatomic)         CLLocationCoordinate2D coordinate;

@end