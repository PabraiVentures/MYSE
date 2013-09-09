//
//  Coreportfolio.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CorePortfolio.h"
#import "CoreStock.h"


@implementation CorePortfolio
@dynamic coreportfolio_id;
@dynamic stocks;
@dynamic totalcashvalue;
@dynamic totalportfoliovalue;
@dynamic owner;

+ (CorePortfolio*)initSelf
{
    CorePortfolio* thePortfolio = [[CorePortfolio alloc] init];
    thePortfolio.stocks = [NSMutableSet set];
    thePortfolio.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
    thePortfolio.totalportfoliovalue   =[NSNumber numberWithFloat:100000.0];
    NSLog(@"initSelf");
    return thePortfolio;
}

-(id) init
{
    
    if (self = [super init])
    {
       // self.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
        NSLog(@"calling coreportfolio init");
    }
    return self;
}

-(id) initWithStocksObject: (CoreStock *) theStock
{
    if (self = [super init])
    {
        [self addStocks:[NSSet setWithObject: theStock ]];
        //self.totalvalue = [NSNumber numberWithDouble:[theStock crntPrice]];
    }
    return self;
}



#pragma mark - Local Getter Methods

-(double) totalStockValue
{
    double value = 0.0;
    for (CoreStock *s in self.stocks)
    {
        value += ([s.openprice doubleValue] * [s.amount doubleValue]);
    }
    return value;
}



-(double) totalPortfolioValue
{
    return [self totalStockValue] + [self totalCashValue];
}

-(double)totalCashValue
{
    return self.totalcashvalue.doubleValue;
}

/**
 Finds a stock in your portfolio based on symbol string
 returns the stock that was found if exists
 returns null if you don't own the stock
 will have amount and price of your stock
 not what was entered into text box/new prices
 */
- (CoreStock *) findStock: (NSString *) symbol
{
    CoreStock *foundStock;
    
    for(CoreStock *s in self.stocks)
    {
        if ([s.symbol isEqual: symbol])
        {
            foundStock = [CoreStock initWithSymbol:s.symbol AndPrice:[s.openprice doubleValue] AndAmount:[s.amount intValue]];
            break;
        }
    }
    return foundStock;
}
@end