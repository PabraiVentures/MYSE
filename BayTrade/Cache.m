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
    if(self = [super init]) {
        
    }
    return self;
}

-(void) addTradeEventFromStock:(CoreStock*) theStock withActionID: (int) actionID
{
    NSManagedObjectContext *moc = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    CoreTradeEvent* tradeevent=[NSEntityDescription insertNewObjectForEntityForName:@"CoreTradeEvent" inManagedObjectContext:moc];
    tradeevent.ticker = [theStock.symbol uppercaseString];
    [tradeevent setValue:[tradeevent assignObjectId] forKey:[tradeevent primaryKeyField]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    
    tradeevent.time = [formatter stringFromDate:[NSDate date]];
    tradeevent.tradeamount = theStock.amount;
    tradeevent.tradeprice = theStock.buyprice;
    tradeevent.actionid = [NSNumber numberWithInt:actionID];
    
    //ADD TRADEEVENT TO COREMODEL TO BE SAVED
    [self.coreModel addTradeeventsObject:tradeevent];// tradevent is now part of the model
    [moc deleteObject:theStock];
    [moc saveOnSuccess:^{
        NSLog(@"You added a trade event by trading a stock!");
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
        [modelPort setValue:[NSNumber numberWithDouble:100000.0] forKey:@"totalcashvalue"];
        [modelPort setValue:[NSNumber numberWithDouble:100000.0] forKey:@"totalportfoliovalue"];
        
        [coreModel setValue:modelPort forKey:@"portfolio"];
        
        [appDelegate.managedObjectContext saveOnSuccess:^{
            NSLog(@"Successfully created new model and portfolio");
            
        }onFailure:^(NSError *error) {
            NSLog(@"Inner fetch error: %@",error);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

- (void) updateCoreModel {
    /********GET COREMODEL FROM STACKMOB***********/
    //download stackmob coremodel and save to local coremodel
    NSFetchRequest *fetchRequest = [self getRequestForUserCoreModel];
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    // execute the request
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        @try {
            self.coreModel = (CoreModel *)[results objectAtIndex:0]; //now we can access coremodel from anywhere
            NSLog(@"succeeded setting CoreModel");
        }
        @catch (NSException *exception) {
            NSLog(@"error setting core model.");
        }
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
}

-(NSFetchRequest*)getRequestForUserCoreModel {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    // query for coremodel for THIS user
    NSString* coreModelRequest = [NSString stringWithFormat:@"user == '%@'", self.userID];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
    return fetchRequest;
}


@end