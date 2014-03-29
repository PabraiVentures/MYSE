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

@synthesize stockColors, totalPortfolioValue, legendScrollView, pieView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

-(void)initPieView
{
    pieView = [[PieView alloc] initWithFrame:CGRectMake(self.frame.size.width/3, 0, self.frame.size.width/2, self.frame.size.height)];
    pieView.stocks = self.stocks;
    pieView.currentPrices = self.currentPrices;
  NSLog(@"PRICES:%@",self.currentPrices);
    pieView.totalPortfolioValue = self.totalPortfolioValue;
    pieView.parent = self;
    [pieView setNeedsDisplay];
    [self addSubview:pieView];
}

-(void)calculateCurrentPrices
{
    totalPortfolioValue = 0;
    self.currentPrices = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) currentStockPrices];
    NSLog(@"ccp totalportval: %f", totalPortfolioValue);
}

-(void)drawLegend
{
    NSLog(@"drawing legend.");
    int itemHeight = 20;
    legendScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, self.frame.size.height)];
    legendScrollView.contentSize = CGSizeMake(legendScrollView.frame.size.width, self.frame.size.height/2 + itemHeight*stockColors.count);
    int currentHeight = 0;
    for (NSString *key in stockColors) {
        UIColor *color = stockColors[key];
        UILabel *newLabel = [[UILabel alloc] init];
        newLabel.textColor = color;
        newLabel.text = key.lowercaseString;
        newLabel.frame = CGRectMake(5, currentHeight, legendScrollView.frame.size.width, itemHeight);
        [legendScrollView addSubview:newLabel];
        currentHeight += itemHeight;
    }
    [self addSubview:legendScrollView];
}

@end

@implementation PieView

@synthesize stocks, currentPrices, totalPortfolioValue, parent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    double maxRadius = 50;
    NSMutableDictionary *radiusDict = [[NSMutableDictionary alloc] init];
    double maxIncrease = 0;
  if (![[self.currentPrices valueForKeyPath:@"query.results.quote" ]respondsToSelector:@selector(objectAtIndex:)]){
    //currentprices.query.results.quote is just a dictionary if theres just one stock. we need to make it an array with 1 object
    self.currentPrices=[self.currentPrices mutableCopy];
    [self.currentPrices setValue:[[self.currentPrices valueForKeyPath:@"query"]mutableCopy ]forKeyPath:@"query"];
    [self.currentPrices setValue:[[self.currentPrices valueForKeyPath:@"query.results"]mutableCopy ]forKeyPath:@"query.results"];
    [self.currentPrices setValue:[[self.currentPrices valueForKeyPath:@"query.results.quote"]mutableCopy ]forKeyPath:@"query.results.quote"];


    NSLog(@"curr prices type is %@", [self.currentPrices class]);

    [self.currentPrices setValue:[NSArray arrayWithObject:[self.currentPrices valueForKeyPath:@"query.results.quote"] ] forKeyPath:@"query.results.quote"];
    NSLog(@"firstif");
  }

    for (int x = 0; x < [[self.currentPrices valueForKeyPath:@"query.results.quote" ] count]; x++) {
        CoreStock *stock = [self.stocks objectAtIndex:0];
        float currentPrice;
        @try {
       int cs=0;
          
          while (![stock.symbol isEqualToString:([(NSDictionary*)[[self.currentPrices valueForKeyPath:@"query.results.quote" ] objectAtIndex:x] valueForKey:@"symbol"])]) {
            cs++;
            if (cs>=[self.stocks count])break;
            stock = [self.stocks objectAtIndex:cs];
            
            
          }

          NSLog(@"CURRENTPRICES:\n\n%@",currentPrices);
          
          currentPrice=    [[[[self.currentPrices valueForKeyPath:@"query.results.quote" ] objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
          NSLog(@"foriter %d",x);

        }
        @catch (NSException *exception) {
            NSLog(@"couldn't find currentprice.");
        }
        CGFloat relativePrice = (stock.buyprice.floatValue != 0 ? currentPrice/stock.buyprice.floatValue : 0);
        if (relativePrice > maxIncrease) maxIncrease = relativePrice;
        [radiusDict setObject:[NSNumber numberWithDouble:relativePrice] forKey:stock.symbol];
    }
    CGFloat currentTime = 0;
  int cs=0;
    parent.stockColors = [[NSMutableDictionary alloc] init];
  NSLog(@"IN Pie %@",[self.currentPrices valueForKeyPath:@"query.results.quote" ]);
      //if current prices is an array
  
    for (int x = 0; x < [[self.currentPrices valueForKeyPath:@"query.results.quote" ] count]; x++) {
      CoreStock *stock = [self.stocks objectAtIndex:0];
      cs=0;
      
      while (![stock.symbol isEqualToString:([(NSDictionary*)[[self.currentPrices valueForKeyPath:@"query.results.quote" ] objectAtIndex:x] valueForKey:@"symbol"])]) {
        cs++;
        if (cs>=[self.stocks count])break;
        stock = [self.stocks objectAtIndex:cs];

        
      }
        float currentPrice=    [[[[self.currentPrices valueForKeyPath:@"query.results.quote" ] objectAtIndex:x] objectForKey:@"LastTradePriceOnly"] floatValue];
        float totalCurrentValue = currentPrice * stock.amount.floatValue;
        double percentOfPie = totalCurrentValue/totalPortfolioValue;
        double radius = [[radiusDict objectForKey:stock.symbol] floatValue] / maxIncrease * maxRadius;
        CGFloat starttime = currentTime; //1 pm = 1/6 rad
        CGFloat endtime = starttime+((2*M_PI)*percentOfPie);  //6 pm = 1 rad
        currentTime = endtime;
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
        [parent.stockColors setValue:randomcolor forKey:stock.symbol];
        [randomcolor set];
        [arc fill];
    
  }
    //rest is CASH
    int radius = maxRadius / maxIncrease;
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
    [parent drawLegend];
}

@end