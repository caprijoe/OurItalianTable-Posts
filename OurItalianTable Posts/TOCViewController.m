//
//  TOCViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TOCViewController.h"

#define LAST_TOC_CATEGORY_KEY   @"LAST_TOC_CATEGORY_KEY"

@interface TOCViewController ()
@property (nonatomic,strong) NSString *pickedCategory;          // category selected in first row of wheel
@property (nonatomic, strong) NSString *pickedDetail;           // detail picked in second row of wheel based on first column selected
@property (nonatomic, strong) NSDictionary *categoryDictionary; // dictionary of first and second columns picker
@property (nonatomic, strong) NSArray *categoryHolder;          // helper to hold first column of dictionary

@end

@implementation TOCViewController
@synthesize pickedCategory = _pickedCategory;
@synthesize pickedDetail = _pickedDetail;
@synthesize categoryDictionary = _categoryDictionary;
@synthesize categoryHolder = _categoryHolder;
@synthesize delegate = _delegate;
@synthesize categorySegmentedController = _categorySegmentedController;
@synthesize detailPicker = _detailPicker;

#pragma mark - Private methods

-(void)resetPickerWhenSegmentSelected {
    
    // save selected picker category to defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.categorySegmentedController.selectedSegmentIndex+1 forKey:LAST_TOC_CATEGORY_KEY];
    [defaults synchronize];
    
    // load pickedCategory based on selectedSegmentIndex
    self.pickedCategory = [self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex];    
    
    // set initial position of picker wheel to row 1 and load into pickedDetail variable
    [self.detailPicker selectRow:0 inComponent:0 animated:NO];
    self.pickedDetail = [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] objectAtIndex:0];
    
    // reload picker
    [self.detailPicker reloadAllComponents];
}


#pragma mark - View lifecycle support 
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // set up filepath to PLIST for PickViewController and helpers
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
    
    // setup helper to hold first column picker content (load plist keys and sort)
    self.categoryHolder = [[[[NSDictionary alloc] initWithContentsOfFile:filePath] allKeys] sortedArrayUsingSelector:@selector(compare:)];    
    
    // Load up category dictionary from PLIST. If incoming object is a NSDictionary, make the keys into an array
    NSMutableDictionary *muteableCategoryDictionary = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[self.categoryHolder count]; i++) {
        id temp = [[[NSDictionary alloc] initWithContentsOfFile:filePath] objectForKey:[self.categoryHolder objectAtIndex:i]];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            [muteableCategoryDictionary setObject:[[temp allKeys] sortedArrayUsingSelector:@selector(compare:)] forKey:[self.categoryHolder objectAtIndex:i]]; 
        } else {
            [muteableCategoryDictionary setObject:[temp sortedArrayUsingSelector:@selector(compare:)] forKey:[self.categoryHolder objectAtIndex:i]];
        }
    }
    self.categoryDictionary = [muteableCategoryDictionary copy];
    
    // remove segments that came in from storyboard, initialize with categories
    [self.categorySegmentedController removeAllSegments];
    int i=0;
    for (NSArray *segment in self.categoryHolder) {
        [self.categorySegmentedController insertSegmentWithTitle:[self.categoryHolder objectAtIndex:i] atIndex:i animated:YES];
        i++;
    }

    // get last selected category from defaults and use that (defaults value is offset by 1 -- so 1, 2, 3 is stored)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int lastCategory = [defaults integerForKey:LAST_TOC_CATEGORY_KEY];
    
    if (lastCategory) {
        self.categorySegmentedController.selectedSegmentIndex = lastCategory - 1;
    } else {
        self.categorySegmentedController.selectedSegmentIndex = 0;
        [defaults setInteger:1 forKey:LAST_TOC_CATEGORY_KEY];
        [defaults synchronize];        
    }
    
    [self resetPickerWhenSegmentSelected];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = CGSizeMake(500, 400);
    self.contentSizeForViewInPopover = size;
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewDidUnload
{
    [self setCategorySegmentedController:nil];
    [self setDetailPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickedDetail = [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (self.categorySegmentedController.selectedSegmentIndex >=0) {
        int i = [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] count];
        return i;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] objectAtIndex:row];
}

#pragma mark - IBActions
- (IBAction)selectCategorySegment:(id)sender {
    [self resetPickerWhenSegmentSelected];
}

- (IBAction)goSearch:(id)sender {

    [self.delegate TOCViewController:sender categoryPicked:self.pickedCategory detailCategoryPicked:self.pickedDetail];
}
@end
