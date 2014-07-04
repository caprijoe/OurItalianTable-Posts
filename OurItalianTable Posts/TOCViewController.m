//
//  TOCViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TOCViewController.h"

@interface TOCViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation TOCViewController

typedef enum {
    food,
    wine,
    wandering
} postType;

typedef enum {
    regionSide,
    foodSide
} componentSides;

#pragma mark - Setters/Getters
// if ivar set to a 0 length string, set it to nil
-(void)setPickedFoodType:(NSString *)pickedFoodType {
    _pickedFoodType = ([pickedFoodType length]) ? pickedFoodType : nil;
}

-(void)setPickedGeo:(NSString *)pickedGeo {
    _pickedGeo = ([pickedGeo length]) ? pickedGeo : nil;
}

#pragma mark - View lifecycle support
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // setup appDelegate for accessing shared properties and methods
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // setup the picker; empty before category segment is selected
    [self resetPickerWhenSegmentSelected];

}

#pragma mark - Private methods
-(void)resetPickerWhenSegmentSelected
{
    
    // reload picker
    [self.detailPicker reloadAllComponents];
    [self.detailPicker selectRow:0 inComponent:0 animated:NO];
    [self.detailPicker selectRow:0 inComponent:1 animated:NO];

    
    // set selected picker item to first item, currently first item is a 0 length string
    switch (self.typeSegmentedController.selectedSegmentIndex) {
        case food:
            self.pickedGeo = [[self.appDelegate.categoryDictionary[@"regions"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            self.pickedFoodType = [[self.appDelegate.categoryDictionary[@"food"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            break;
            
        case wine:
            self.pickedGeo = [[self.appDelegate.categoryDictionary[@"regions"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            self.pickedFoodType = nil;
            break;
            
        case wandering:
            self.pickedGeo = [[self.appDelegate.categoryDictionary[@"regions"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            self.pickedFoodType = nil;
            break;
            
        default:
            self.pickedGeo = [[self.appDelegate.categoryDictionary[@"regions"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            self.pickedFoodType = [[self.appDelegate.categoryDictionary[@"food"] allKeys] sortedArrayUsingSelector: @selector(compare:)][0];
            break;
    }
}

#pragma mark - UIPicker delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (self.typeSegmentedController.selectedSegmentIndex) {
        case food:
            switch (component) {
                case regionSide:
                    return [self.appDelegate.categoryDictionary[@"regions"] count];
                case foodSide:
                    return [self.appDelegate.categoryDictionary[@"food"] count];
                default:
                    return 0;
            }
            
        case wine:
            switch (component) {
                case regionSide:
                    return [self.appDelegate.categoryDictionary[@"regions"] count];
                case foodSide:
                    return 0;
                default:
                    return 0;
            }

        case wandering:
            switch (component) {
                case regionSide:
                    return [self.appDelegate.categoryDictionary[@"regions"] count];
                case foodSide:
                    return 0;
                default:
                    return 0;
            }
            
        default: // when nothing is selected on segmented controller
            switch (component) {
                case regionSide:
                    return [self.appDelegate.categoryDictionary[@"regions"] count];
                case foodSide:
                    return [self.appDelegate.categoryDictionary[@"food"] count];
                default:
                    return 0;
            }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    switch (component) {
        case foodSide:
            return [[self.appDelegate.categoryDictionary[@"food"] allKeys] sortedArrayUsingSelector:@selector(compare:)][row];
        case regionSide:
            return [[self.appDelegate.categoryDictionary[@"regions"] allKeys] sortedArrayUsingSelector:@selector(compare:)][row];
        default:
            return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case foodSide:
            self.pickedFoodType = [[self.appDelegate.categoryDictionary[@"food"] allKeys] sortedArrayUsingSelector:@selector(compare:)][row];
            break;
        case regionSide:
            self.pickedGeo = [[self.appDelegate.categoryDictionary[@"regions"] allKeys]sortedArrayUsingSelector:@selector(compare:)][row];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)selectedTypeSegment:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex != UISegmentedControlNoSegment) {
        self.pickedPostType = self.appDelegate.typeArray[sender.selectedSegmentIndex];
        [self resetPickerWhenSegmentSelected];
    }
}

- (IBAction)goCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
