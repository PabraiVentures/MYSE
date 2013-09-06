//
//  Corestock.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CoreStock.h"


@implementation CoreStock

@dynamic amount;
@dynamic buyprice;
@dynamic closeprice;
@dynamic currentprice;
@dynamic name;
@dynamic openprice;
@dynamic sellprice;
@dynamic stock_id;
@dynamic symbol;
@dynamic totalvalue;

<<<<<<< HEAD
@end
=======

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
>>>>>>> 44eb4ec6010b847ac85a48b4a4e8569408c99ce7
