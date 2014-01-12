//
//  Post+Query.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 1/7/14.
//  Copyright (c) 2014 Our Italian Table. All rights reserved.
//

#import "Post+Query.h"

@implementation Post (Query)

+(NSArray *)queryPostForDistinctProperty:(NSString *)property
                                withPredicate:(NSPredicate *)predicate
                       inManagedObjectContext:(NSManagedObjectContext *)context
{
    // get the list of DISTINCT geos in DB
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[property];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) NSLog(@"error at geoReferenceInfo = %@",error);
    
    // Assuming we got at least one, build the list of Annotations
    if (objects == nil) {
        
        // Handle the error.
        NSLog(@"nil array returned at geoReferenceInfo build");
        return nil;
        
    } else {
        return objects;
    }
}

@end
