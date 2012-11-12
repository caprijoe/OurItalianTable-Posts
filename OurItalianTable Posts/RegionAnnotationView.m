//
//  RegionAnnotationView.m
//  RegionAnnotationView
//
//  Created by Joseph Becci on 12/29/11.
//  Copyright (c) 2012 Our Italian Table. All rights reserved.
//

#import "RegionAnnotationView.h"
#import "RegionAnnotation.h"

@implementation RegionAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(120.0, 35.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{    
    // setup and load uiimageview to hold flag/coat of arms
    CGRect targetRect = CGRectMake(5.0, 5.0, 25.0, 25.0);
    UIImageView *flagImageView = [[UIImageView alloc]initWithFrame:targetRect];
    flagImageView.contentMode = UIViewContentModeScaleAspectFit;
    flagImageView.image = [UIImage imageNamed:((RegionAnnotation *)self.annotation).flagURL];
    
    // setup and load uilabel to hold title text
    CGRect targetTitle = CGRectMake(35.0, 0.0, 80.0, 35.0);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:targetTitle];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = ((RegionAnnotation *)self.annotation).title;
    
    // draw rect with rounded corners and fill it in
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddArcToPoint(path, NULL, 120.0, 0.0, 120.0, 5.0, 5.0);
    CGPathAddArcToPoint(path,NULL, 120.0, 35.0, 115.0, 35.0, 5.0);
    CGPathAddArcToPoint(path, NULL, 0.0, 35.0, 0.0, 30.0, 5.0);
    CGPathAddArcToPoint(path, NULL, 0.0, 0.0, 5.0, 0.0, 5.0);
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:28.0/255.0 green:68.0/255.0 blue:17.0/255.0 alpha:1.0].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
    
    // add views to annotation subview
    [self addSubview:flagImageView];
    [self addSubview:titleLabel];
}

@end
