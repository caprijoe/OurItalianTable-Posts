//
//  Post.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/5/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Tag;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * bookmarked;
@property (nonatomic, retain) NSString * geo;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * postAuthor;
@property (nonatomic, retain) NSString * postHTML;
@property (nonatomic, retain) NSData * postIcon;
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * postName;
@property (nonatomic, retain) NSDate * postPubDate;
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
