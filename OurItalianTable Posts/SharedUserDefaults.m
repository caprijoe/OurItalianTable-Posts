//
//  SharedLocationManager.m
//  TomatoRadar
//
//  Created by Joseph Becci on 7/1/13.
//  Copyright (c) 2013 Joseph Becci. All rights reserved.
//

#import "SharedUserDefaults.h"

@interface SharedUserDefaults()
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation SharedUserDefaults

- (id)init {
    self = [super init];
    
    if(self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        
        // set up defaults
        
        // Last Table of Contents selected defaults to the first one
        NSDictionary *appDefaults = @{LAST_TOC_CATEGORY_KEY: @0
//                                      ,UPDATE_OVER_CELLULAR: @YES
                                      };
        
        // set defaults
        [self.defaults registerDefaults:appDefaults];
    }
    
    return self;
}

+ (SharedUserDefaults*)sharedSingleton {
    static SharedUserDefaults* sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [SharedUserDefaults new];
        }
    }
    
    return sharedSingleton;
}

-(void)setObjectWithKey:(NSString *)key withObject:(id)obj {

    [self.defaults setObject:obj forKey:key];
    [self.defaults synchronize];

}

-(id)getObjectWithKey:(NSString *)key {
    
    return [self.defaults objectForKey:key];
    
}


@end
