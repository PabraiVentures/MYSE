//
//  Portfolio.m
//  Stocks
//
//  Created by Jamie Tahirkheli on 6/8/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Portfolio.h"
#import "Stock.h"

@implementation Portfolio
@synthesize owner;
@synthesize stockList;
@synthesize value;



+ (Portfolio*)initSelf
{
    Portfolio* thePortfolio = [[Portfolio alloc] init];
    thePortfolio.stockList = [NSMutableArray arrayWithCapacity:10];
    thePortfolio.cash = 100000.00;
    return thePortfolio;
}

-(id) init
{
    
    if (self = [super init])
    {
        self.stockList = [NSMutableArray arrayWithCapacity:10];
        self.cash = 100000.00;
    }
    return self;
}

-(id) initWithStock: (Stock *) theStock
{
    if (self = [super init])
    {
        owner = @"Jamie";
        [stockList addObject: theStock];
        value = [theStock crntPrice];
    }
    return self;
}

//should I make this bool?
-(bool) addStock:(Stock *)addedStock
{
    @try {
        [self.stockList addObject:addedStock];
        return true;
    }
    @catch (NSException *exception) {
        NSLog(@"exception adding stock: %@", exception);
        return false;
    }
}

-(void) calculateValue
{
    for (int i = 0; i <[self.stockList count]; i++)
    {
        Stock *s = [self.stockList objectAtIndex:i];
        self.value += (s.openPrice * s.amount);
    }
}

/**
 Finds a stock in your portfolio based on symbol string
 returns the stock that was found if exists
 returns null if you don't own the stock
 will have amount and price of your stock
 not what was entered into text box/new prices
 */
- (Stock *) findStock: (NSString *) symbol
{
    Stock *foundStock = NULL;
    for(int i = 0; i < [self.stockList count]; i++)
    {
        Stock* s = [self.stockList objectAtIndex:i];
        if ([s.symbol isEqual: symbol])
        {
            //matching = i;
            foundStock = [Stock initWithSymbol:s.symbol AndPrice:s.openPrice AndAmount:s.amount];
            break;
        }
    }
    return foundStock;
}

@end
