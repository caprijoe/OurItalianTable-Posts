//
//  MapAnnotation.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 2/4/12.
//  Copyright (c) 2012 OurItalianTable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Post.h"

@interface MapAnnotation : NSObject <MKAnnotation>

// public property
@property (nonatomic,strong) Post *entry;

@end
