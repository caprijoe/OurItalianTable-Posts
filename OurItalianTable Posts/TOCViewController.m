//
//  TOCViewController.m
//  oitPosts
//
//  Created by Joseph Becci on 4/27/12.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "TOCViewController.h"

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

#pragma mark Private methods

-(void)resetPickerWhenSegmentSelected {
    
    // load pickedCategory based on selectedSegmentIndex
    self.pickedCategory = [self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex];    
    
    // set initial position of picker wheel to row 1 and load into pickedDetail variable
    [self.detailPicker selectRow:0 inComponent:0 animated:NO];
    self.pickedDetail = [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] objectAtIndex:0];
    
    // reload picker
    [self.detailPicker reloadAllComponents];
}


#pragma mark -
#pragma view lifecycle support

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // set up content for PickViewController and helpers
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CategoryDictionary" ofType:@"plist"];
    
    // setup helper to hold first column picker content (load plist keys and sort)
    self.categoryHolder = [[[[NSDictionary alloc] initWithContentsOfFile:filePath] allKeys] sortedArrayUsingSelector:@selector(compare:)];    
    
    // FIX THIS!!
    self.categoryDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];    
    

    
    // remove segments that came in from storyboard, initialize with categories
    [self.categorySegmentedController removeAllSegments];
    int i=0;
    for (NSArray *segment in self.categoryHolder) {
        [self.categorySegmentedController insertSegmentWithTitle:[self.categoryHolder objectAtIndex:i] atIndex:i animated:YES];
        i++;
    }

    // initialize segmented control to first item and load into category variable
    self.categorySegmentedController.selectedSegmentIndex = 0;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else  
        return YES;
}

#pragma mark - 
#pragma mark UIPicker methods

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
    if (self.categorySegmentedController.selectedSegmentIndex >=0)
    return [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] count];
    else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[self.categoryDictionary objectForKey:[self.categoryHolder objectAtIndex:self.categorySegmentedController.selectedSegmentIndex]] objectAtIndex:row];
}

#pragma mark - 
#pragma IBActions

- (IBAction)selectCategorySegment:(id)sender {
    [self resetPickerWhenSegmentSelected];
}

- (IBAction)goSearch:(id)sender {

    [self.delegate TOCViewController:sender categoryPicked:self.pickedCategory detailCategoryPicked:self.pickedDetail];
}
@end
