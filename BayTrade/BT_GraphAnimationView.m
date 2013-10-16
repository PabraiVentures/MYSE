//
//  BT_GraphAnimationView.m
//  BayTrade
//
//  Created by John Luttig on 10/16/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_GraphAnimationView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation BT_GraphAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [bezier removeFromSuperlayer];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [[UIColor greenColor] set];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    bezier = [[CAShapeLayer alloc] init];
    [bezierPath moveToPoint:CGPointMake(10, self.frame.size.height-110)];
    [bezierPath addLineToPoint:CGPointMake(80, self.frame.size.height-170)];
    [bezierPath addLineToPoint:CGPointMake(150, self.frame.size.height-100)];
    [bezierPath addLineToPoint:CGPointMake(220, self.frame.size.height-200)];
    [bezierPath addLineToPoint:CGPointMake(290, self.frame.size.height-300)];
    bezier.path          = bezierPath.CGPath;
    bezier.strokeColor   = [UIColor greenColor].CGColor;
    bezier.fillColor     = [UIColor clearColor].CGColor;
    bezier.lineWidth     = 5.0;
    bezier.strokeStart   = 0.0;
    bezier.strokeEnd     = 1.0;
    [self.layer addSublayer:bezier];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = 1.0;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    animateStrokeEnd.delegate = self;
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
}

@end
