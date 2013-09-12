//
//  BT_PieChartView.m
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_PieChartView.h"
#import "CoreStock.h"
#import "BT_TabBarController.h"
#import "Controller.h"

@implementation BT_PieChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
        //self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
        [self calculateCurrentPrices];
    }
    return self;
}

-(void)calculateCurrentPrices
{
    //eventually just take from loaded values in splash screen
    
    totalPortfolioValue = 0;
    self.currentPrices = [[NSMutableArray alloc] init];
    for (CoreStock *stock in self.stocks) {
        NSLog(@"finding currentPrices");
        [self.currentPrices addObject:[Controller fetchQuotesFor:[NSArray arrayWithObject:stock.symbol]]];
    }
    totalPortfolioValue = self.userCache.coreModel.portfolio.totalportfoliovalue.doubleValue;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawing rect");
    
    CGFloat currentTime = 0;
    
    for (int x = 0; x < [self.stocks count]; x++) {
        CoreStock *stock = [self.stocks objectAtIndex:x];
        float currentPrice = [[[self.currentPrices objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        float totalCurrentValue = currentPrice * stock.amount.floatValue;
        
        NSLog(@"drawing arc");
        
        double percentOfPie = totalCurrentValue/totalPortfolioValue;
        NSLog(@"percent: %f", percentOfPie);
        
        CGFloat starttime = currentTime; //1 pm = 1/6 rad
        CGFloat endtime = starttime+((2*M_PI)*percentOfPie);  //6 pm = 1 rad
        currentTime = endtime;
        CGFloat relativePrice = currentPrice/stock.buyprice.floatValue;
        
        CGFloat standardRadius = 100;
        CGFloat radius = standardRadius*relativePrice;

        //draw arc
        //CGPoint center = CGPointMake(standardRadius+10,standardRadius+10);
        CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
        [arc moveToPoint:center];
        CGPoint next;
        next.x = center.x + radius * cos(starttime);
        next.y = center.y + radius * sin(starttime);
        [arc addLineToPoint:next]; //go one end of arc
        [arc addArcWithCenter:center radius:radius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
        [arc addLineToPoint:center]; //back to center
        
        CGFloat red =  (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        CGFloat blue = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        CGFloat green = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        [color set];
        [arc fill];
    }
}

@end