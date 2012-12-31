//
//  TOCViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

// Protocol for call back when search button is clicked; a) close popover/modal and b) return selected categories
@protocol  TOCViewController

-(void)didPickUsingCategory:(NSString *)category
             detailCategory:(NSString *)detailCategory;

@end

@interface TOCViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>;

// delegate for callback from popover/modal, invoked when search button clicked
@property (nonatomic, strong) id<TOCViewController> delegate;
@property (nonatomic, strong) NSArray *geosInUseList;

// Outlets
@property (nonatomic, weak) IBOutlet UISegmentedControl *categorySegmentedController;
@property (nonatomic, weak) IBOutlet UIPickerView *detailPicker;

// Actions
- (IBAction)selectCategorySegment:(id)sender;   // wheel for selecting detail TOC item
- (IBAction)goSearch:(id)sender;                // search button

@end
