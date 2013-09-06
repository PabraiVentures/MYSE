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

@synthesize totalcashvalue;
@dynamic portfolio_id;
@synthesize stocks;
@synthesize totalportfoliovalue;

@synthesize owner;

+ (CorePortfolio*)initSelf
{
    CorePortfolio* thePortfolio = [[CorePortfolio alloc] init];
    thePortfolio.stocks = [NSMutableArray arrayWithCapacity:10];
    return thePortfolio;
}



-(id) initWithStock: (Stock *) theStock
{
    if (self = [super init])
    {
        owner = @"Jamie";
        [self.stocks addObject: theStock];
        //self.totalvalue = [NSNumber numberWithDouble:[theStock crntPrice]];
    }
    return self;
}

-(bool) addStocksObject:(Stock *)addedStock
{
    @try {
        [self.stocks addObject:addedStock];
        return true;
    }
    @catch (NSException *exception) {
        NSLog(@"exception adding stock: %@", exception);
        return false;
    }
}

#pragma mark - Local Getter Methods

-(double) totalStockValue
{
    double value = 0.0;
    for (Stock *s in self.stocks)
    {
        value += (s.openPrice * s.amount);
    }
    return value;
}

-(double) totalPortfolioValue
{
    return [self totalStockValue] + [[self totalcashvalue]doubleValue];
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
            foundStock = [CoreStock initWithSymbol:s.symbol AndPrice:s.openprice.doubleValue AndAmount:s.amount.intValue];
            break;
        }
    }
    return foundStock;
}
@end