//
//  TOCViewController.m
//  OurItalianTable Posts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TOCViewController.h"

#define LAST_TOC_CATEGORY_KEY   @"LAST_TOC_CATEGORY_KEY"

@interface TOCViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *pickedCategory;         // category selected in first row of wheel
@property (nonatomic, strong) NSString *pickedDetail;           // detail picked in second row of wheel based on first column selected
@property (nonatomic, strong) NSArray *categoryHolder;          // helper to hold first column of dictionary
@property (nonatomic, strong) NSArray *pickerContentsHolder;    // hold the contents of each of the three potential pickers
@end

@implementation TOCViewController

#pragma mark - View lifecycle support 
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // set background to white
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // setup appDelegate for accessing shared properties and methods
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // configure done button
    [self.appDelegate configureButton:self.doneButton];
    
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
        
        // initialize with categories from the pre-loaded dictionary from the appDelegate
        int i=0;
        for (NSArray *segment in [[self.appDelegate.categoryDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            [self.categorySegmentedController insertSegmentWithTitle:[self.categoryHolder objectAtIndex:i] atIndex:i animated:YES];
            i++;
        }
    }
    
    // configure segmented controller
    self.categorySegmentedController.selectedSegmentIndex = [self getLastSelectedSegmentedController];
    
    // setup the picker
    [self resetPickerWhenSegmentSelected];
    
}

-(void)viewDidLoad {
    
    [super viewDidLoad];

    CGSize size = CGSizeMake(500, 400);
    self.contentSizeForViewInPopover = size;
    self.view.backgroundColor = [UIColor grayColor];

}

#pragma mark - Private methods

-(void)saveLastSelectedSegmentedController:(int)lastSegment {
    
    // save away last segment clicked .. only non-zero #s can be saved in NSUserDefaults so offset by one
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:lastSegment+1 forKey:LAST_TOC_CATEGORY_KEY];
    [defaults synchronize];
    
}

-(int)getLastSelectedSegmentedController {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int lastCategory = [defaults integerForKey:LAST_TOC_CATEGORY_KEY];
    
    if (lastCategory) {
        return lastCategory - 1;
    } else {
        [defaults setInteger:1 forKey:LAST_TOC_CATEGORY_KEY];
        [defaults synchronize];
        return 0;
    }
}

-(void)resetPickerWhenSegmentSelected {
    
    // save selected picker category to defaults
    [self saveLastSelectedSegmentedController:self.categorySegmentedController.selectedSegmentIndex];
    
    // load pickedCategory based on selectedSegmentIndex
    self.pickedCategory = [self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex];
    
    // set initial position of picker wheel to row 1 and load into pickedDetail variable
    [self.detailPicker selectRow:0 inComponent:0 animated:NO];
    self.pickedDetail = self.pickerContentsHolder[self.categorySegmentedController.selectedSegmentIndex][0];
    
    // reload picker
    [self.detailPicker reloadAllComponents];
}

#pragma mark - Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

#pragma mark - UIPicker delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (self.categorySegmentedController.selectedSegmentIndex >=0) {
        return [self.pickerContentsHolder[self.categorySegmentedController.selectedSegmentIndex] count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return self.pickerContentsHolder[self.categorySegmentedController.selectedSegmentIndex][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickedDetail = self.pickerContentsHolder[self.categorySegmentedController.selectedSegmentIndex][row];
}

#pragma mark - IBActions
- (IBAction)selectCategorySegment:(id)sender {
    [self resetPickerWhenSegmentSelected];
}

- (IBAction)goSearch:(id)sender {
    [self.delegate didPickUsingCategory:self.pickedCategory detailCategory:self.pickedDetail];
}
@end
