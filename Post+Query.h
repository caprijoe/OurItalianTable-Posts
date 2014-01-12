//
//  Post+Query.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/7/14.
//  Copyright (c) 2014 Our Italian Table. All rights reserved.
//

#import "Post.h"

@interface Post (Query)

+(NSArray *)queryPostForDistinctProperty:(NSString *)property
                                withPredicate:(NSPredicate *)predicate
                       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
