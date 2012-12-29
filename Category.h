//
//  Category.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/6/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * categoryString;
@property (nonatomic, retain) NSSet *whichPosts;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addWhichPostsObject:(Post *)value;
- (void)removeWhichPostsObject:(Post *)value;
- (void)addWhichPosts:(NSSet *)values;
- (void)removeWhichPosts:(NSSet *)values;

@end