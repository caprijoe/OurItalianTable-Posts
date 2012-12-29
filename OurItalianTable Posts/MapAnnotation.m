//
//  MapAnnotation.m
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

-(NSString *)title
{
    return self.entry.postName;
}

-(NSString *)subtitle 
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
        
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.entry.postPubDate]];
}

-(CLLocationCoordinate2D) coordinate 
{
    return CLLocationCoordinate2DMake(self.entry.latitude, self.entry.longitude);
}

@end
