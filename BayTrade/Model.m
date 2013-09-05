//
//  Model.m
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/22/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Model.h"
#import "BT_TradeEvent.h"
#import "CoreTradeEvent.h"
#import "StackMob.h"

@implementation Model

//-(void)assignPort: (Portfolio*) myPort
//{
//   self.modelPort = myPort;
//}
@synthesize userID;
@synthesize coreModel;
-(id) init
{
        if(self = [super init])
        {
            self.modelPort = [[CorePortfolio alloc] init];
            //self.modelPort.value = [self.modelPort totalPortfolioValue];
            self.eventArray = [NSMutableArray arrayWithCapacity:0]; 
        }
    return self;
}

-(void) updateHistory:(Stock* )theStock andAmount: (int) theAmount andID: (int) ID
{
    //create a tradeEvent
    //add to self.eventArray
    BT_TradeEvent* tradeEvent = [[BT_TradeEvent alloc] init];
    tradeEvent.ticker = theStock.symbol;
    tradeEvent.tradePrice = theStock.openPrice;//change to purchase price
    tradeEvent.tradeAmount = theAmount;
    tradeEvent.actionID = ID;
//    /***Get date string*****/
//    NSDate *now = [[NSDate alloc] init];
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"HH:mm MMM dd, yyyy"];
//    NSString *dateString = [format stringFromDate:now];
//    /***Get date string*****/
//    tradeEvent.date = dateString;
//    
//    [self.eventArray addObject:tradeEvent];
    
    
    
    NSManagedObjectContext *moc = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    /****create tradeevent and put it into managedObjectContext (so it can be saved later), THEN fill it up with its data****/
    CoreTradeEvent* tradeevent=[NSEntityDescription insertNewObjectForEntityForName:@"CoreTradeEvent" inManagedObjectContext:moc];
    tradeevent.ticker=theStock.symbol;
    [tradeevent setValue:[tradeevent assignObjectId] forKey:[tradeevent primaryKeyField]];
    
    //get the time as a string
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    tradeevent.time=dateString;
    
    tradeevent.tradeamount=[NSNumber numberWithInt:theAmount];
    tradeevent.tradeprice=[NSNumber numberWithDouble:theStock.openPrice];
    tradeevent.actionid=[NSNumber numberWithInt:ID];
    
    /*****DONE CREATING TRADEEVENT INSIDE MANAGEDOBJECTCONTEXT*******/
    
    
    
    //ADD TRADEEVENT TO COREMODEL TO BE SAVED
    [self.coreModel addTradeeventsObject:tradeevent];// tradevent is now part of the model
    
    
}

@end