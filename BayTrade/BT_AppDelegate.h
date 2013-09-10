//
//  BT_AppDelegate.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BT_LoginViewController.h"
#import "BT_PortfolioViewController.h"
#import "CoreStock.h"

@class SMCoreDataStore;
@class SMClient;
@interface BT_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SMCoreDataStore *coreDataStore;
@property (strong, nonatomic) SMClient *client;
@property (strong, nonatomic) BT_LoginViewController *loginView;
@property (strong, nonatomic) BT_PortfolioViewController *portfolioView;

@property (strong, nonatomic) CoreStock *selectedPortfolioStock;

@end
//goto https://developer.stackmob.com/ios-sdk/developer-guide#Datastore