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
    //eventually just take from loaded values in splash screen
    
    totalPortfolioValue = 0;
    self.currentPrices = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) currentStockPrices];
    
//    self.currentPrices = [[NSMutableArray alloc] init];
//    for (CoreStock *stock in self.stocks) {
//        NSLog(@"finding currentPrices");
//        [self.currentPrices addObject:[Controller fetchQuotesFor:[NSArray arrayWithObject:stock.symbol]]];
//    }
    totalPortfolioValue = self.userCache.coreModel.portfolio.totalportfoliovalue.doubleValue;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat currentTime = 0;
    
    for (int x = 0; x < [self.stocks count]; x++) {
        CoreStock *stock = [self.stocks objectAtIndex:x];
        float currentPrice = [[[self.currentPrices objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        float totalCurrentValue = currentPrice * stock.amount.floatValue;
        
        double percentOfPie = totalCurrentValue/totalPortfolioValue;
        
        CGFloat starttime = currentTime; //1 pm = 1/6 rad
        CGFloat endtime = starttime+((2*M_PI)*percentOfPie);  //6 pm = 1 rad
        currentTime = endtime;
        CGFloat relativePrice = currentPrice/stock.buyprice.floatValue;
        
        CGFloat standardRadius = 100;
        CGFloat radius = standardRadius*relativePrice;
        if (relativePrice > 1){
            radius = standardRadius*(1+(log(relativePrice)/log(1.2)));//equation to slightly exaggerate positive gains for better visualization
        }

        //draw arc
        CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
        [arc moveToPoint:center];
        CGPoint next;
        next.x = center.x + radius * cos(starttime);
        next.y = center.y + radius * sin(starttime);
        [arc addLineToPoint:next]; //go one end of arc
        [arc addArcWithCenter:center radius:radius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
        [arc addLineToPoint:center]; //back to center
        
        //CGFloat red =  (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        //CGFloat blue = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        //CGFloat green = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
        
        //UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        //[color set];
        UIColor *randomcolor = [UIColor numberedFlatColor:x];
        [randomcolor set];
        [arc fill];
    }
}

@end