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

@synthesize stockColors, legendView, totalPortfolioValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)calculateCurrentPrices
{
    totalPortfolioValue = 0;
    self.currentPrices = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) currentStockPrices];
    NSLog(@"ccp totalportval: %f", totalPortfolioValue);
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
    double maxRadius = 50;
    NSLog(@"max radius: %f", maxRadius);
    stockColors = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *radiusDict = [[NSMutableDictionary alloc] init];
    double maxIncrease = 0;
    NSLog(@"currentprices size: %i", self.currentPrices.count);
    NSLog(@"stocks size: %i", self.stocks.count);
    for (int x = 0; x < [self.currentPrices count]; x++) {
        CoreStock *stock = [self.stocks objectAtIndex:x];
        float currentPrice;
        @try {
            currentPrice = [[[self.currentPrices objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        }
        @catch (NSException *exception) {
            NSLog(@"couldn't find currentprice.");
        }
        CGFloat relativePrice = (stock.buyprice.floatValue != 0 ? currentPrice/stock.buyprice.floatValue : 0);
        NSLog(@"relative price of %@: %f", stock.symbol, relativePrice);
        if (relativePrice > maxIncrease) maxIncrease = relativePrice;
        [radiusDict setObject:[NSNumber numberWithDouble:relativePrice] forKey:stock.symbol];
    }
    NSLog(@"radiusdict: %@", radiusDict);
    CGFloat currentTime = 0;
    for (int x = 0; x < [self.currentPrices count]; x++) {
        NSLog(@"currenttime: %f", currentTime);
        CoreStock *stock = [self.stocks objectAtIndex:x];
        float currentPrice = [[[self.currentPrices objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        float totalCurrentValue = currentPrice * stock.amount.floatValue;
        double percentOfPie = totalCurrentValue/totalPortfolioValue;
        NSLog(@"total port val: %f:", totalPortfolioValue);
        double radius = [[radiusDict objectForKey:stock.symbol] floatValue];
        NSLog(@"radius1: %f", radius);
        radius /= maxIncrease;
        NSLog(@"radius2: %f", radius);
        CGFloat starttime = currentTime; //1 pm = 1/6 rad
        CGFloat endtime = starttime+((2*M_PI)*percentOfPie);  //6 pm = 1 rad
        currentTime = endtime;
        radius *= maxRadius;
        NSLog(@"radius3: %f", radius);
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
    int radius = maxRadius;
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