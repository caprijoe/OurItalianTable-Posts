//
//  RegionAnnotation.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 7/29/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RegionAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *regionName;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) NSString *flagURL;
@property (nonatomic) NSInteger correspondingSection;

@end
