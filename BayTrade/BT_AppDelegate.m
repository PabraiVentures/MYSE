//
//  BT_AppDelegate.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
/*
 This is the first code that is run upon opening the app.
 It owns the:
 ManagedObjectModel      -> core data model that has the model, portfolio, etc...
 ManagedObjectContext    -> manages all of the objects
 fbSession               -> the connection to Facebook
 coreDataStore           -> where the objects/data gets saved
 SMClient                -> the connection to StackMob
 */

#import "BT_AppDelegate.h"
#import "StackMob.h"
#import "CorePortfolio.h"
#import "CoreModel.h"
#import <CoreData/CoreData.h>
#import "Controller.h"
@class NSManagedObject;

@implementation BT_AppDelegate
@synthesize managedObjectModel=_managedObjectModel;
@synthesize loginView, selectedPortfolioStock, userCache;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    [FBProfilePictureView class]; //to make prof pic nice/right size
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"ef598654-95fb-4ecd-8f13-9309f2fcad0f"];
    
    //STACKMOB CORE DATA STORE initialization
    self.coreDataStore = [self.client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    self.client.userPrimaryKeyField = @"user_id";
    
    self.userCache = [[Cache alloc] init]; //TODO should this be here?
    self.userCache.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    [self performSelectorInBackground:@selector(backgroundUpdateModel) withObject:nil];
    //[self performSelectorInBackground:@selector(downloadCurrentStocksInfo) withObject:nil];
    return YES;
}

//- (void)updateCoreModel
//{
//    //STACKMOB CORE DATA STORE initialization
//    NSLog(@"updating core model");
//        /********GET COREMODEL FROM STACKMOB***********/
//        //download stackmob coremodel and save to local coremodel
//        NSFetchRequest *fetchRequest = [self getRequestForUserCoreModel];
//        //get the object context to work with stackmob data
//        self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
//        
//        // execute the request
//        [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
//            @try {
//                self.userCache.coreModel = (CoreModel *)[results objectAtIndex:0]; //now we can access coremodel from anywhere
//                NSLog(@"self.coremodel.stocks count: %i", self.userCache.coreModel.portfolio.stocks.count);
//                NSLog(@"succeeded setting CoreModel");
//            }
//            @catch (NSException *exception) {
//                NSLog(@"error setting core model.");
//            }
//        } onFailure:^(NSError *error) {
//            NSLog(@"There was an error! %@", error);
//        }];
//        NSLog(@"updated core model.");
//}

-(void)updateCoreModel
{
    @try {
        self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CorePortfolio"];
        // query for tradeevents for THIS user
        fetchRequest.includesPendingChanges = false;
        NSString* getRightModel = [NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userCache.userID ];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightModel]];
        [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *models) {
            if([models count] > 0) self.userCache.coreModel.portfolio = [models firstObject];
            [self performSelectorInBackground:@selector(downloadCurrentStocksInfo) withObject:nil];
        } onFailure:^(NSError *error) {
            NSLog(@"Error fetching: %@", error);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Error fetching core model in setCoreModel");
    }
}

- (void) backgroundUpdateModel
{
    [NSThread sleepForTimeInterval:60.0];//update every 60 seconds
    NSLog(@"appdelegate: updating coremodel in background");
    [self performSelectorInBackground:@selector(updateCoreModel) withObject:nil];
    [self performSelectorInBackground:@selector(backgroundUpdateModel) withObject:nil];
}

-(NSFetchRequest*)getRequestForUserCoreModel {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    // query for coremodel for THIS user
    NSString* coreModelRequest = [NSString stringWithFormat:@"user == '%@'", self.userCache.userID];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
    return fetchRequest;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // attempt to extract a token from the url
    NSLog(@"opening url");
    bool didWork = [FBAppCall handleOpenURL:url
                          sourceApplication:sourceApplication
                                withSession:FBSession.activeSession];
    if (didWork) {
        NSLog(@"extracted token from FB URL; calling updateview");
        [loginView updateView];
    }
    return didWork;
}

-(void)downloadCurrentStocksInfo
{
    NSLog(@"downloading current stocks info APPD");
    NSMutableArray *currentPrices = [[NSMutableArray alloc] init];
    @try {
        currentPrices = [[NSMutableArray alloc] init];
        for (CoreStock *stock in self.userCache.coreModel.portfolio.stocks) {
            NSLog(@"got quote for symbol %@", stock.symbol);
            [currentPrices addObject:[Controller fetchQuotesFor:[NSArray arrayWithObject:stock.symbol]]];
        }
    }
    @catch(NSException* e) {
        NSLog(@"Error appd loading data\n%@",e);
        [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
        return;
    }
    [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received notification.");
    [self updateCoreModel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession: FBSession.activeSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) return _managedObjectModel;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"themodel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

@end