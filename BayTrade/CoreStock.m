//
//  Corestock.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CoreStock.h"
#import "StackMob.h"
#import "Controller.h"

@implementation CoreStock

@dynamic amount;
@dynamic buyprice;
@dynamic symbol;

+(CoreStock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) thePrice AndAmount: (int) theAmount
{
    CoreStock *theStock=[NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:[[[SMClient defaultClient]coreDataStore] contextForCurrentThread]];    
    //initialize variables
    
    theStock.symbol = [theSymbol uppercaseString];
    theStock.buyprice = [NSNumber numberWithFloat: 0.00];
    theStock.amount = [NSNumber numberWithFloat: theAmount];
    // theStock.totalValue = theAmount * theOpen;
    
    [theStock setValue:[theStock assignObjectId] forKey:[theStock primaryKeyField]];

    theStock.buyprice=[NSNumber numberWithFloat: thePrice];
    return theStock;

}

-(id)init{
   CoreStock* thestock = [NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:[[[SMClient defaultClient]coreDataStore] contextForCurrentThread]];
    [thestock setValue:[thestock assignObjectId] forKey:[thestock primaryKeyField]];

    return thestock;
}

-(void)setSymbol:(NSString *)symbol{
    self.symbol=symbol;
    return;
}

@end