//
//  SharedUserDefaults.h
//  TomatoRadar
//
//  Created by Joseph Becci on 7/1/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LAST_UPDATE_TO_CORE_DB  @"LAST_UPDATE_TO_CORE_DB_DATE"
#define LAST_TOC_CATEGORY_KEY   @"LAST_TOC_CATEGORY_KEY"
#define UPDATE_OVER_CELLULAR    @"UPDATE_OVER_CELLULAR"


@interface SharedUserDefaults : NSObject

+ (SharedUserDefaults *)sharedSingleton;
-(void)setObjectWithKey:(NSString *)key withObject:(id)obj;
-(id)getObjectWithKey:(NSString *)key;

@end
