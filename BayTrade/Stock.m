//
//  Stock.m
//  Stocks
//
//  Created by Jamie Tahirkheli on 6/8/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Stock.h"

@implementation Stock
@synthesize name;
@synthesize symbol;
@synthesize openPrice;
@synthesize buyPrice;
@synthesize sellPrice;
@synthesize closePrice;
@synthesize crntPrice;
@synthesize amount;
@synthesize totalValue;
@synthesize purchasedPrice;
-(id) initWithName: (NSString *) theName AndSymbol: (NSString *) theSymbol AndOpen: (double) theOpen
{
    Stock *theStock=[Stock alloc];
    
    //initialize variables
    
    theStock.name = theName;
    theStock.symbol = theSymbol;
    theStock.openPrice = theOpen;//replace with method to get open price.
    theStock.buyPrice = 0.00;    //replace with method to get buy price.
    theStock.sellPrice = 0.00;   //replace with method to get sell price.
    theStock.closePrice = 0.00;  //replace with method to get close price.
    theStock.crntPrice = 0.00;   //replace with method to get current price.
    
    return theStock;
}

-(id) initWithName: (NSString *) theName AndSymbol: (NSString *) theSymbol
{
    Stock *theStock=[[Stock alloc]init];
    
    //initialize variables
    
    theStock.name = theName;
    theStock.symbol = theSymbol;
    theStock.openPrice = 0.00;//replace with method to get open price.
    theStock.buyPrice = 0.00;    //replace with method to get buy price.
    theStock.sellPrice = 0.00;   //replace with method to get sell price.
    theStock.closePrice = 0.00;  //replace with method to get close price.
    theStock.crntPrice = 0.00;   //replace with method to get current price.
    
    
    return theStock;
}

+(Stock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) thePrice AndAmount: (int) theAmount;
{
    Stock *theStock=[[Stock alloc] init];
    
    //initialize variables
    
    theStock.symbol = theSymbol;
    theStock.openPrice = thePrice;//replace with method to get open price.
    theStock.buyPrice = 0.00;    //replace with method to get buy price.
    theStock.sellPrice = 0.00;   //replace with method to get sell price.
    theStock.closePrice = 0.00;  //replace with method to get close price.
    theStock.crntPrice = 0.00;   //replace with method to get current price.
    theStock.amount = theAmount;
   // theStock.totalValue = theAmount * theOpen;
  
    
    theStock.purchasedPrice=thePrice;
    return theStock;
}

-(void) initToZero
{
    self.symbol = @"";
    self.openPrice = 0.00;//replace with method to get open price.
    self.buyPrice = 0.00;    //replace with method to get buy price.
    self.sellPrice = 0.00;   //replace with method to get sell price.
    self.closePrice = 0.00;  //replace with method to get close price.
    self.crntPrice = 0.00;   //replace with method to get current price.
    
    return;
}

-(void) calculateValue
{
    self.totalValue = self.openPrice * self.amount;
}
@end


