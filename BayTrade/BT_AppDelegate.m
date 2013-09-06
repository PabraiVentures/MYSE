//
//  BT_AppDelegate.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
/*
 This is the first code that is run on openning of the app.
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
@synthesize session = _session;
@synthesize loginView;
//Session and object model are used for stackmob data transfer


/*---------------------application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions------------------
    This runs when the application loads. We set up our Facebook profile picture class, the stackmob client
 for communication, and set up our core data store with stackmob and our  managedObjectModel which has our
 themodel.xcdatamodelId schema loaded. We let the stackmob client know that the userPrimaryKeyField is "user_id"
 which is not the default. This maps to the user in the core data model.
 --------------------------------------------------------------------------------------------------------------*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class]; //to make prof pic nice/right size
    

    
    //SM Client Initialization
    // Override point for customization after application launch.
    // Assuming your variable is declared SMClient *client;
    //SMClient *client;
    /*
     Starting the connection to StackMob (How it Authenticates)
    */
    self.client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"ef598654-95fb-4ecd-8f13-9309f2fcad0f"];
    
    
    //STACKMOB CORE DATA STORE initialization
    // This assumes you have already initialized your SMClient instance,
    // and have a NSManagedObjectModel property called managedObjectModel
    
    self.coreDataStore = [self.client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    self.client.userPrimaryKeyField = @"user_id";
    return YES;
}

// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of FBAppCall the provided
// session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    NSLog(@"opening url");
    NSLog(@"self.session 1: %@", self.session);
    bool didWork = [FBAppCall handleOpenURL:url
                          sourceApplication:sourceApplication
                                withSession:FBSession.activeSession];
    NSLog(@"self.session 2: %@", self.session);
    NSLog(@"did work? 1 = yes --> %i", didWork);
    if (didWork) {
        NSLog(@"it worked; calling updateview");
        [loginView updateView];
    }
    return didWork;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}


// FBSample logic
// Whether it is in applicationWillTerminate, in applicationDidEnterBackground, or in some other part
// of your application, it is important that you close an active session when it is no longer useful
// to your application; if a session is not properly closed, a retain cycle may occur between the block
// and an object that holds a reference to the session object; close releases the handler, breaking any
// inadvertant retain cycles
- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [self.session close];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"themodel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
@end