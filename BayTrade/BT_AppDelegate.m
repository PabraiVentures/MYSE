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
    [FBProfilePictureView class]; //to make prof pic nice/right size
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"ef598654-95fb-4ecd-8f13-9309f2fcad0f"];
    
    //STACKMOB CORE DATA STORE initialization
    self.coreDataStore = [self.client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    self.client.userPrimaryKeyField = @"user_id";
    
    self.userCache = [[Cache alloc] init]; //TODO should this be here?
    self.userCache.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSLog(@"did finish launching with options");
    [self performSelectorInBackground:@selector(updateCoreModelInBackground) withObject:nil];
    return YES;
}

- (void)updateCoreModelInBackground
{
    sleep(60.0);
    [self performSelectorInBackground:@selector(updateCoreModel) withObject:nil];
    [self performSelectorInBackground:@selector(updateCoreModelInBackground) withObject:nil];
}

- (void)updateCoreModel
{
    NSLog(@"updating core model");
    [userCache updateCoreModel];
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
    NSLog(@"downloading current stocks info");
    NSLog(@"usercache stocks: %@", self.userCache.coreModel.portfolio);
    NSMutableArray *currentPrices = [[NSMutableArray alloc] init];
    @try {
        for (CoreStock *stock in self.userCache.coreModel.portfolio.stocks) {
            [currentPrices addObject:[Controller fetchQuotesFor:[NSArray arrayWithObject:stock.symbol]]];
        }
    }
    @catch(NSException* e) {
        NSLog(@"Error spashsscreen loading data\n%@",e);
        [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
        [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
        return;
    }
    [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received notification.");
    [self updateCoreModel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession: FBSession.activeSession];
}

- (void)applicationWillTerminate:(UIApplication *)application {
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