//
//  RegionAnnotation.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/29/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "RegionAnnotation.h"

@implementation RegionAnnotation

@synthesize regionName = _regionName;
@synthesize travelPostCount = _travelPostCount;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

-(NSString *)title
{
    return self.regionName;
}

-(NSString *)subtitle 
{
    
    return [NSString stringWithFormat:@"%i travel posts",self.travelPostCount]; 
}

-(CLLocationCoordinate2D) coordinate 
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

@end
