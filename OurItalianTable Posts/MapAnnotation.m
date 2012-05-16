//
//  MapAnnotation.m
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize entry =_entry;


-(NSString *)title
{
    return self.entry.postName;
}

-(NSString *)subtitle 
{
    
    return [self.entry.postPubDate substringToIndex:16]; 
}

-(CLLocationCoordinate2D) coordinate 
{
    return self.entry.coordinate;
}

@end
