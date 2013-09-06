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
    NSLog(@"initializing model.m");
        if(self = [super init])
        {
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CorePortfolio"];
//            
//            // query for coreportfolio for THIS user
//            //NSString* corePortfolioRequest=[NSString stringWithFormat:@"user == '%@'",self.userID];
//            //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:corePortfolioRequest]];
//            NSManagedObjectContext *managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
//            
//            // execute the request
//            [managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
//                NSLog(@"model.m results: %@",results);
//                
//                @try {
//                    NSManagedObject* myPortfolio=[results objectAtIndex:0];
//                    self.modelPort = (CorePortfolio *) myPortfolio;
//                    NSLog(@"succeeded!");
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"error in model.m: %@", exception);
//                }
//                
//            } onFailure:^(NSError *error) {
//                NSLog(@"There was an error! %@", error);
//            }];

            self.modelPort = [CorePortfolio initSelf];
            NSLog(@"self.modelport.cashval: %f", self.modelPort.totalcashvalue);
            
            //self.modelPort.value = [self.modelPort totalPortfolioValue];
            self.eventArray = [NSMutableArray arrayWithCapacity:0]; 
        }
        else {
            NSLog(@"error initializing model.m");
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