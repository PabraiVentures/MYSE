//
//  BT_PieChartView.m
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_PieChartView.h"
#import "CoreStock.h"
#import "BT_AppDelegate.h"
#import "Controller.h"
#import "UIColor+BTFlatColors.h"

@implementation BT_PieChartView

@synthesize stockColors, legendView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self calculateCurrentPrices];
    }
    return self;
}

-(void)calculateCurrentPrices
{
    //TODO just take from loaded values in splash screen
    totalPortfolioValue = 0;
    self.currentPrices = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) currentStockPrices];
    totalPortfolioValue = self.userCache.coreModel.portfolio.totalportfoliovalue.doubleValue;
}

-(void)drawLegend
{
    legendView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
    int legendHeight = legendView.frame.size.height;
    int itemHeight = (stockColors.count > 0? legendHeight / stockColors.count : 1);
    int currentHeight = 0;
    for (NSString *key in stockColors) {
        UIColor *color = stockColors[key];
        UILabel *newLabel = [[UILabel alloc] init];
        newLabel.textColor = color;
        newLabel.text = key.lowercaseString;
        newLabel.frame = CGRectMake(5, currentHeight, legendView.frame.size.width, itemHeight);
        [legendView addSubview:newLabel];
        currentHeight += itemHeight;
    }
    [self addSubview:legendView];
}

- (void)drawRect:(CGRect)rect
{
    double maxRadius = self.frame.size.height / 2;
    CGFloat currentTime = 0;
    stockColors = [[NSMutableDictionary alloc] init];
    for (int x = 0; x < [self.currentPrices count]; x++) {
        CoreStock *stock = [self.stocks objectAtIndex:x];
        float currentPrice = [[[self.currentPrices objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        float totalCurrentValue = currentPrice * stock.amount.floatValue;
        
        double percentOfPie = totalCurrentValue/totalPortfolioValue;
        
        CGFloat starttime = currentTime; //1 pm = 1/6 rad
        CGFloat endtime = starttime+((2*M_PI)*percentOfPie);  //6 pm = 1 rad
        currentTime = endtime;
        CGFloat relativePrice = currentPrice/stock.buyprice.floatValue;
        
        CGFloat radius = relativePrice;
        NSLog(@"radius1: %f", radius);
        if (relativePrice > 1){
            radius = 1+(log(relativePrice)/log(1.4));//equation to slightly exaggerate positive gains for better visualization
        }
        NSLog(@"RADIUS: %f", radius);
        radius *= maxRadius;
        //draw arc
        CGPoint center = CGPointMake(self.frame.size.width*2/3, self.frame.size.height*1/2);
        UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
        [arc moveToPoint:center];
        CGPoint next;
        next.x = center.x + radius * cos(starttime);
        next.y = center.y + radius * sin(starttime);
        [arc addLineToPoint:next]; //go one end of arc
        [arc addArcWithCenter:center radius:radius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
        [arc addLineToPoint:center]; //back to center
        
        UIColor *randomcolor = [UIColor numberedFlatColor:x];
        [stockColors setValue:randomcolor forKey:stock.symbol];
        [randomcolor set];
        [arc fill];
    }
    //rest is CASH
    int radius = 70;
    CGPoint center = CGPointMake(self.frame.size.width*2/3, self.frame.size.height*1/2);
    UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
    [arc moveToPoint:center];
    CGPoint next;
    next.x = center.x + radius * cos(currentTime);
    next.y = center.y + radius * sin(currentTime);
    [arc addLineToPoint:next]; //go one end of arc
    [arc addArcWithCenter:center radius:radius startAngle:currentTime endAngle:0 clockwise:YES]; //add the arc
    [arc addLineToPoint:center]; //back to center
    UIColor *randomcolor = [UIColor flatGreenColor];
    [randomcolor set];
    [arc fill];
    NSLog(@"stockcolors: %@", stockColors);
    [self drawLegend];
}

@end