//
//  Model.m
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/22/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Cache.h"
#import "CoreTradeEvent.h"
#import "StackMob.h"
#import "CoreStock.h"
#import "BT_AppDelegate.h"
#import "User.h"
#import "CoreModel.h"

@implementation Cache

@synthesize userID;
@synthesize coreModel;

-(id) init
{
    NSLog(@"initializing model.m");
    if(self = [super init]) {
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
    }
    return self;
}

-(void) updateHistory:(CoreStock* )theStock andAmount: (int) theAmount andID: (int) ID
{
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
    
    tradeevent.tradeamount = [NSNumber numberWithInt:theAmount];
    tradeevent.tradeprice = [NSNumber numberWithDouble:theStock.buyprice.doubleValue]; //TODO is this ok?
    tradeevent.actionid = [NSNumber numberWithInt:ID];
    
    /*****DONE CREATING TRADEEVENT INSIDE MANAGEDOBJECTCONTEXT*******/

    //ADD TRADEEVENT TO COREMODEL TO BE SAVED
    [self.coreModel addTradeeventsObject:tradeevent];// tradevent is now part of the model
    [moc deleteObject:theStock];

    [moc saveOnSuccess:^{
        NSLog(@"You updated the model object by selling a stock!");
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];

}

+(void) makeNewModelWithFBID:(NSString*)userID
{
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    //download existing user to put into soon to be created model
    //select the table to search - in this case, the User table
    NSFetchRequest *requestUserWithUserID = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    NSLog(@"USER_ID ---> %@", userID);
    //"WHERE" clause for fetch request.
    NSString* whereClause=[ NSString stringWithFormat:@"user_id == '%@'",userID ];
    
    //DO the request
    [requestUserWithUserID setPredicate:[NSPredicate predicateWithFormat:whereClause]];
    NSLog(@"request where %@", whereClause);
    
    // execute the request to get the correct user
    appDelegate.managedObjectContext = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    [appDelegate.managedObjectContext executeFetchRequest:requestUserWithUserID onSuccess:^(NSArray *results) {
        /*********************************BLOCK START****************************************************/
        NSLog(@"# users with this userID: %d", [results count]);
        NSLog(@"need EVERYTHING");
        
        
        //so create coremodel and coreportfolio
        appDelegate.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
        
        //create a core model object
        CoreModel *coreModel=[NSEntityDescription insertNewObjectForEntityForName:@"CoreModel" inManagedObjectContext:appDelegate.managedObjectContext];
        
        //set the coremodel's primary key value in the coremodel table
        [coreModel setValue:[coreModel assignObjectId] forKey:[coreModel primaryKeyField]];
        
        User *theUser = (User *)[results objectAtIndex:0];
        NSLog(@"the user is: %@", theUser.user_id);
        
        //place model into user table
        [theUser setValue:coreModel forKey:@"coremodel"];
        
        //create portfolio
        CorePortfolio* modelPort=[NSEntityDescription insertNewObjectForEntityForName:@"CorePortfolio" inManagedObjectContext:appDelegate.managedObjectContext];
        [modelPort setValue:[modelPort assignObjectId] forKey:[modelPort primaryKeyField]];
        //add portfolio to the model
        [coreModel setValue:modelPort forKey:@"portfolio"];
        [modelPort setValue:[NSNumber numberWithDouble:100000.0] forKey:@"totalcashvalue"];
        [modelPort setValue:[NSNumber numberWithDouble:100000.0] forKey:@"totalportfoliovalue"];
        
        
        [appDelegate.managedObjectContext saveOnSuccess:^{
            NSLog(@"Successfully created new model and portfolio");
            
        }onFailure:^(NSError *error) {
            NSLog(@"There was an error inner %@",error);
            
        }];
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching:outer %@", error);
    }];
}

@end