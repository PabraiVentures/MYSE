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
#import "BT_AppDelegate.h"
#import "Model.h"
@interface BT_LoginViewController ()

@end

@implementation BT_LoginViewController

@synthesize loginButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [loginButton setImage:[UIImage imageNamed:@"login_pressed.png"] forState:UIControlStateHighlighted];
    if (!FBSession.activeSession.isOpen) {
        // create a fresh session object
        FBSession.activeSession = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
    else {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    NSLog(@"button pressed");
    // get the app delegate so that we can access the session property
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (FBSession.activeSession.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [FBSession.activeSession closeAndClearTokenInformation];
        NSLog(@"1");
        
    } else {
        NSLog(@"2");
        if (FBSession.activeSession.state != FBSessionStateCreated) {
            NSLog(@"app delegate session state isn't created");
            // Create a new, logged out session.
            FBSession.activeSession = [[FBSession alloc] init];
        }
        //assign self to appdelegate as the loginview so that token can be passed
        appDelegate.loginView = self;
        // if the session isn't open, let's open it now and present the login UX to the user
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            token = session.accessTokenData.accessToken;
            NSLog(@"opening appdelegate session");
            NSLog(@"local session: %@", session);
            // and here we make sure to update our UX according to the new session state
            //[self performSelector:@selector(updateView) withObject:nil afterDelay:0.5];
            //NSLog(@"After Updateview");
        }];
    }
}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    NSLog(@"inside UpdateView");
    // get the app delegate, so that we can reference the session property
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (FBSession.activeSession.isOpen) {
        NSLog(@"appdelegate session is open");
        //Gets FacebookID and creates a StackMob user if needed
        NSLog(@"token: %@", FBSession.activeSession.accessTokenData.accessToken);
        [[SMClient defaultClient] loginWithFacebookToken:FBSession.activeSession.accessTokenData.accessToken createUserIfNeeded:YES usernameForCreate:nil onSuccess:^(NSDictionary *result) {
            NSLog(@"Logged in with StackMob. \nData: %@",[result valueForKey:@"user_id"]);
            //download StackMob user object and see if it has a model
            //save user_id to defaults plist
            [self saveToDefaultsPlist: result];
            
            /************SEARCH MODELS FOR THIS USER***************/
            [self searchModelsForUser:result andDelegate:appDelegate];
            
            // valid account UI is shown whenever the session is open
            [self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
            [self.statusText setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", FBSession.activeSession.accessTokenData.accessToken]];
            [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
            
        } onFailure:^(NSError *error) {
            NSLog(@"Error in UpdateView: %@", error);
        }];
    } else {
        NSLog(@"appdelegate session isn't open");
        // login-needed account UI is shown whenever the session is closed
        [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
        [self.statusText setText:@"Login to create a link to fetch account data"];
    }
NSLog(@"end of update view");
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
    NSFetchRequest *requestModelByUserID = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    //search string for users with the model's userID
    NSString* userWithUserID=[ NSString stringWithFormat:@"user == '%@'",userID ];
    
    [requestModelByUserID setPredicate:[NSPredicate predicateWithFormat:userWithUserID]];
    NSLog(@"%@", userWithUserID);
    
    // execute the request
    appDelegate.managedObjectContext = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    [appDelegate.managedObjectContext executeFetchRequest:requestModelByUserID onSuccess:^(NSArray *results) {
        
        NSLog(@"Number of Results: %d",[results count]);
        NSLog(@"Results: %@", results);
        if([results count] == 0)
        {
            NSLog(@"model  doesnt exist");
           [Model  makeNewModelWithFBID:   [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"]];
 
            NSLog(@"got past making model");
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

@end