//
//  TOCViewController.h
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TOCViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>;

// public properties
@property (nonatomic, strong) NSString *pickedGeo;                  // category selected in first row of wheel
@property (nonatomic, strong) NSString *pickedFoodType;             // detail picked in second row of wheel based on first column selected
@property (nonatomic, strong) NSString *pickedPostType;             // picked type of post

// Outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedController;
@property (nonatomic, weak) IBOutlet UIPickerView *detailPicker;

// Actions
- (IBAction)goCancel:(id)sender;                                    // cancel button
- (IBAction)selectedTypeSegment:(UISegmentedControl *)sender;

@end