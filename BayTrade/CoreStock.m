//
//  Corestock.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CoreStock.h"
#import "StackMob.h"

@implementation CoreStock

@dynamic amount;
@dynamic buyprice;
@dynamic closeprice;
@dynamic currentprice;
@dynamic name;
@dynamic openprice;
@dynamic sellprice;
@dynamic corestock_id;
@dynamic symbol;
@dynamic totalvalue;


+(CoreStock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) thePrice AndAmount: (int) theAmount
{
    CoreStock *theStock=[NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:[[[SMClient defaultClient]coreDataStore] contextForCurrentThread]];    
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
-(id)init{
   CoreStock* thestock=    [NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:[[[SMClient defaultClient]coreDataStore] contextForCurrentThread]];
    [thestock setValue:[thestock assignObjectId] forKey:[thestock primaryKeyField]];

    return thestock;
}
-(void)setSymbol:(NSString *)symbol{
    self.symbol=symbol;
    return;
}
@end
