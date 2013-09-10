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
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BT_AppDelegate.h"
#import "Cache.h"

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
                [self updateView];
            }];
        }
    }
    else {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    NSLog(@"button pressed");
    // get the app delegate so that we can access the session property
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (FBSession.activeSession.isOpen) {
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
        }];
    }
}

// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    if (FBSession.activeSession.isOpen) {
        //Gets FacebookID and creates a StackMob user if needed
        [[SMClient defaultClient] loginWithFacebookToken:FBSession.activeSession.accessTokenData.accessToken createUserIfNeeded:YES usernameForCreate:nil onSuccess:^(NSDictionary *result) {
            NSLog(@"Logged in with StackMob.");
            //download StackMob user object and see if it has a model
            //save user_id to defaults plist
            [self saveDefaultUser:result];
            [self searchForUser:result];
            
            // valid account UI is shown whenever the session is open
            [self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
            [self.statusText setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@", FBSession.activeSession.accessTokenData.accessToken]];
            [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
            
        } onFailure:^(NSError *error) {
            NSLog(@"Error in UpdateView: %@", error);
        }];
    } else {
        NSLog(@"fbsession session isn't open");
        // login-needed account UI is shown whenever the session is closed
        [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
        [self.statusText setText:@"Login to create a link to fetch account data"];
    }
}

//Saves user_id to defaults plist
- (void)saveDefaultUser: (NSDictionary *) model
{
    NSUserDefaults  *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[model valueForKey:@"user_id"] forKey:@"userID"];
    [defaults synchronize];
}

//Creates string from FbID to search coremodel table on StackMob for the right user's model
-(void) searchForUser: (NSDictionary *) user
{
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSString *userID = [NSString stringWithFormat:@"%@",[user valueForKey:@"user_id"]];
    NSFetchRequest *requestModelByUserID = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    //search string for users with the model's userID
    NSString* userWithUserID = [NSString stringWithFormat:@"user == '%@'",userID ];
    
    [requestModelByUserID setPredicate:[NSPredicate predicateWithFormat:userWithUserID]];
    
    appDelegate.managedObjectContext = [[[SMClient defaultClient] coreDataStore] contextForCurrentThread];
    
    [appDelegate.managedObjectContext executeFetchRequest:requestModelByUserID onSuccess:^(NSArray *results) {
        if([results count] == 0)
        {
            NSLog(@"model for user %@ doesnt exist; creating new model", userID);
            [Cache  makeNewModelWithFBID:[[NSUserDefaults standardUserDefaults] stringForKey:@"userID"]];
            NSLog(@"created new model");
        }
        else {
            NSLog(@"found %i model(s) on SM that match %@!", [results count], userID);
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end