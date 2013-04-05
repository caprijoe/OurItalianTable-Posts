//
//  Post.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 3/16/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Tag;

@interface Post : NSManagedObject

@property (nonatomic) BOOL bookmarked;
@property (nonatomic, retain) NSString * geo;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, retain) NSString * postAuthor;
@property (nonatomic, retain) NSString * postHTML;
@property (nonatomic, retain) NSData * postIcon;
@property (nonatomic) int64_t postID;
@property (nonatomic, retain) NSString * postName;
@property (nonatomic) NSTimeInterval postPubDate;
@property (nonatomic, retain) NSString * postURLstring;
@property (nonatomic, retain) NSSet *whichCategories;
@property (nonatomic, retain) NSSet *whichTags;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addWhichCategoriesObject:(Category *)value;
- (void)removeWhichCategoriesObject:(Category *)value;
- (void)addWhichCategories:(NSSet *)values;
- (void)removeWhichCategories:(NSSet *)values;

- (void)addWhichTagsObject:(Tag *)value;
- (void)removeWhichTagsObject:(Tag *)value;
- (void)addWhichTags:(NSSet *)values;
- (void)removeWhichTags:(NSSet *)values;

@end
