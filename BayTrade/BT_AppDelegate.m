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
@class NSManagedObject;

@implementation BT_AppDelegate
@synthesize managedObjectModel=_managedObjectModel;
@synthesize loginView, selectedPortfolioStock;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class]; //to make prof pic nice/right size
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"ef598654-95fb-4ecd-8f13-9309f2fcad0f"];
    
    //STACKMOB CORE DATA STORE initialization
    self.coreDataStore = [self.client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    self.client.userPrimaryKeyField = @"user_id";
    return YES;
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