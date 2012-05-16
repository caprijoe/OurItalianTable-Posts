//
//  MapAnnotation.h
//  oitPosts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "postRecord.h"

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) PostRecord *entry;

@end
