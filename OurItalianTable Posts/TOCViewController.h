//
//  TOCViewController.h
//  oitPosts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TOCViewController;

// Protocol for call back when search button is clicked; a) close popover/modal and b) return selected categories
@protocol  TOCViewController <NSObject>                                            
-(void)TOCViewController:(TOCViewController *)sender
          categoryPicked:(NSString *)category
    detailCategoryPicked:(NSString *)detailCategory;
@end

@interface TOCViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>;

// delegate for callback from popover/modal, invoked when search button clicked
@property (nonatomic,weak) id<TOCViewController> delegate;

// Outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedController;
@property (weak, nonatomic) IBOutlet UIPickerView *detailPicker;

// Actions
- (IBAction)selectCategorySegment:(id)sender;   // wheel for selecting detail TOC item
- (IBAction)goSearch:(id)sender;                // search button

@end
