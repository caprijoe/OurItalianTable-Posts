//
//  TOCViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TOCViewController.h"
#import "SharedUserDefaults.h"

@interface TOCViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *pickedCategory;         // category selected in first row of wheel
@property (nonatomic, strong) NSString *pickedDetail;           // detail picked in second row of wheel based on first column selected
@property (nonatomic, strong) NSArray *categoryHolder;          // helper to hold first column of dictionary
@property (nonatomic, strong) NSArray *pickerContentsHolder;    // hold the contents of each of the three potential pickers
@property (nonatomic) int selectedSegment;
@end

@implementation TOCViewController
@synthesize selectedSegment = _selectedSegment;

#pragma mark - Setters/getters
-(int)selectedSegment
{
    int i = [[[SharedUserDefaults sharedSingleton] getObjectWithKey:LAST_TOC_CATEGORY_KEY] intValue];
    
    // the saved segment should be greater than or equal to 0. if so, return it, else return 0
    if (i >= 0)
        return i;
    else
        return 0;
}

-(void)setSelectedSegment:(int)selectedSegment
{
    // if segment if greater than 0, save it and set ivar
    if (selectedSegment >= 0) {
        [[SharedUserDefaults sharedSingleton] setObjectWithKey:LAST_TOC_CATEGORY_KEY withObject:[NSNumber numberWithInt:selectedSegment]];
        _selectedSegment = selectedSegment;
    }
}

#pragma mark - View lifecycle support
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // setup appDelegate for accessing shared properties and methods
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // setup reference arrays
    {
        // the categories in the segmented controller
        self.categoryHolder = [[self.appDelegate.categoryDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        // an array with each object the picker contents depending on which segmented button is clicked
        NSMutableArray *tempPickerContents = [NSMutableArray array];
        for (NSArray *category in self.categoryHolder) {
            [tempPickerContents addObject:[[self.appDelegate.categoryDictionary[category] allKeys] sortedArrayUsingSelector:@selector(compare:)]];
        }
        self.pickerContentsHolder = [tempPickerContents copy];
    }
    
    // setup segmented controller
    {
        // remove segments that came in from storyboard
        [self.categorySegmentedController removeAllSegments];
        
        // add the segments
        [self.categoryHolder enumerateObjectsUsingBlock:^(id segment, NSUInteger i, BOOL *stop) {
            [self.categorySegmentedController insertSegmentWithTitle:segment atIndex:i animated:YES];
        }];
    }
    
    // setup the picker
    [self resetPickerWhenSegmentSelected];
    
}

#pragma mark - Private methods
-(void)resetPickerWhenSegmentSelected
{
    // configure segmented controller
    self.categorySegmentedController.selectedSegmentIndex = self.selectedSegment;
    
    // load pickedCategory based on selectedSegmentIndex
    self.pickedCategory = self.categoryHolder[self.selectedSegment];
    
    // set initial position of picker wheel to row 1 and load into pickedDetail variable
    [self.detailPicker selectRow:0 inComponent:0 animated:NO];
    self.pickedDetail = self.pickerContentsHolder[self.selectedSegment][0];
    
    // reload picker
    [self.detailPicker reloadAllComponents];
}

#pragma mark - UIPicker delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (self.selectedSegment >=0) {
        return [self.pickerContentsHolder[self.selectedSegment] count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return self.pickerContentsHolder[self.selectedSegment][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickedDetail = self.pickerContentsHolder[self.selectedSegment][row];
}

#pragma mark - IBActions
- (IBAction)selectCategorySegment:(UISegmentedControl *)sender
{
    self.selectedSegment = sender.selectedSegmentIndex;
    [self resetPickerWhenSegmentSelected];
}

- (IBAction)goSearch:(id)sender
{
    [self.delegate didPickUsingCategory:self.pickedCategory detailCategory:self.pickedDetail];
}
@end
