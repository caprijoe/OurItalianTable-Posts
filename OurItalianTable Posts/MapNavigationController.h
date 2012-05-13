//
//  MapNavigationController.h
//  oitPosts
//
//  Created by Joseph Becci on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OITBrain.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface MapNavigationController : UINavigationController <SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) OITBrain *myBrain;
@end
