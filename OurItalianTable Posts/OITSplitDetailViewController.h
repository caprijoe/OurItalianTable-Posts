//
//  OITSplitDetailViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 12/11/13.
//  Copyright (c) 2013 Our Italian Table. All rights reserved.
//

#import "OITViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface OITSplitDetailViewController : OITViewController <SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end
