//
//  BT_loginViewController.m
//  BayTrade
//
//  Created by Jamie Tahirkheli on 8/13/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_LoginViewController.h"
#import "BT_AppDelegate.h"
#import "StackMob.h"
#import "StackMobPush.h"
#import "User.h"
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
@interface BT_LoginViewController ()

@end

@implementation BT_LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    // get the app delegate so that we can access the session property
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
            NSLog(@"After Updateview\n");
        }];
    }
    

}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    
    NSLog(@"inside UpdateView\n");
    // get the app delegate, so that we can reference the session property
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        
        //Gets FacebookID and creates a StackMob user if needed
        [[SMClient defaultClient] loginWithFacebookToken:FBSession.activeSession.accessTokenData.accessToken createUserIfNeeded:YES usernameForCreate:nil onSuccess:^(NSDictionary *result) {
            NSLog(@"Logged in with StackMob. \nData: %@",[result valueForKey:@"user_id"]);
            //download StackMob user object and see if it has a model
           
            //save user_id to defaults plist
            [self saveToDefaultsPlist: result];
            
            /************SEARCH MODELS FOR THIS USER***************/
            [self searchModelsForUser:result andDelegate:appDelegate];
            
            // valid account UI is shown whenever the session is open
            [self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
            [self.statusText setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
                                      appDelegate.session.accessTokenData.accessToken]];
            [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
         
        } onFailure:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
        [self.statusText setText:@"Login to create a link to fetch account data"];
    }
}

//Creates a new model in StackMob for the new user based on FbUserID
- (void)makeNewModel : (BT_AppDelegate *) appDelegate andResult : (NSDictionary *) result
{
    NSLog(@"******%@", result);
    //download existing user to put into soon to be created model
    NSString *userID = [NSString stringWithFormat:@"%@",[result valueForKey:@"user_id"]];
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
        NSManagedObject* coremodel=[NSEntityDescription insertNewObjectForEntityForName:@"Coremodel" inManagedObjectContext:appDelegate.managedObjectContext];
        
        //set the coremodel's primary key value in the coremodel table
        [coremodel setValue:[coremodel assignObjectId] forKey:[coremodel primaryKeyField]];
        
        User *theUser = (User *)[results objectAtIndex:0];
        NSLog(@"the user is: %@", theUser.user_id);
        
        //place model into user table
        [theUser setValue:coremodel forKey:@"coremodel"];
        
        //create portfolio
        NSManagedObject* coreportfolio=[NSEntityDescription insertNewObjectForEntityForName:@"Coreportfolio" inManagedObjectContext:appDelegate.managedObjectContext];
        [coreportfolio setValue:[coreportfolio assignObjectId] forKey:[coreportfolio primaryKeyField]];
        //add portfolio to the model
        [coremodel setValue:coreportfolio forKey:@"portfolio"];
        [coreportfolio setValue:[NSNumber numberWithDouble:100000] forKey:@"cashvalue"];
        [coreportfolio setValue:[NSNumber numberWithDouble:100000] forKey:@"totalvalue"];
        
        
        [appDelegate.managedObjectContext saveOnSuccess:^{
            NSLog(@"Successfully created new model and portfolio");
            
        }onFailure:^(NSError *error) {
            NSLog(@"There was an error inner %@",error);
            
        }];
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching:outer %@", error);
    }];
    
}

- (void)viewDidUnload
{
    self.loginButton = nil;
    self.statusText = nil;
    
    [super viewDidUnload];
}

//Saves user_id to defaults plist
- (void)saveToDefaultsPlist: (NSDictionary *) result
{
    NSUserDefaults  *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[result valueForKey:@"user_id"] forKey:@"userID"];
    [defaults synchronize];
}

//Creates string from FbID to search coremodel table on StackMob for the right user's model
-(void) searchModelsForUser : (NSDictionary *) result andDelegate : (BT_AppDelegate* ) appDelegate
{
    NSString *userID = [NSString stringWithFormat:@"%@",[result valueForKey:@"user_id"]];
    NSFetchRequest *requestModelByUserID = [[NSFetchRequest alloc] initWithEntityName:@"Coremodel"];
    //search string for users with the model's userID
    NSString* userWithUserID=[ NSString stringWithFormat:@"user == '%@'",userID ];
    
    [requestModelByUserID setPredicate:[NSPredicate predicateWithFormat:userWithUserID]];
    NSLog(@"%@", userWithUserID);
    
    // execute the request
    appDelegate.managedObjectContext = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    [appDelegate.managedObjectContext executeFetchRequest:requestModelByUserID onSuccess:^(NSArray *results) {
        
        NSLog(@"Results of search: %d",[results count]);
        if([results count] == 0)
        {
            NSLog(@"model exists?: %d", [results count]);
            [self makeNewModel:appDelegate andResult:result];
            NSLog(@"got past making model");
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

@end