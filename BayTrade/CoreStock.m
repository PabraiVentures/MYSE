//
//  Corestock.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CoreStock.h"


@implementation CoreStock

@synthesize amount;
@synthesize buyprice;
@synthesize closeprice;
@synthesize currentprice;
@synthesize name;
@synthesize openprice;
@synthesize sellprice;
@synthesize stock_id;
@synthesize symbol;
@synthesize totalvalue;


+(CoreStock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) thePrice AndAmount: (int) theAmount
{
    CoreStock *theStock=[[CoreStock alloc] init];
    
    //initialize variables
    
    theStock.symbol = theSymbol;
    theStock.openprice = [NSNumber numberWithFloat: thePrice];//replace with method to get open price.
    theStock.buyprice = [NSNumber numberWithFloat: 0.00];    //replace with method to get buy price.
    theStock.sellprice = [NSNumber numberWithFloat: 0.00];   //replace with method to get sell price.
    theStock.closeprice = [NSNumber numberWithFloat: 0.00];  //replace with method to get close price.
    theStock.currentprice = [NSNumber numberWithFloat: 0.00];   //replace with method to get current price.
    theStock.amount = [NSNumber numberWithFloat: theAmount];
    // theStock.totalValue = theAmount * theOpen;
    
    
    theStock.buyprice=[NSNumber numberWithFloat: thePrice];
    return theStock;
}
@end