//
//  BT_SecondViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import <FacebookSDK/FacebookSDK.h>

@interface BT_TradeViewController : UIViewController <FBLoginViewDelegate>
@property (nonatomic, strong) Model *userModel;
@property (weak, nonatomic) IBOutlet UILabel *valueDisplay;
@property (weak, nonatomic) IBOutlet UILabel *cashDisplay;
@property (weak, nonatomic) IBOutlet UITextField *symbolField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property(weak,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *investorName;
- (IBAction)buyButtonClicked:(id)sender;
- (IBAction)sellButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
- (NSMutableArray *) accountForPrevOwnedStock : (NSString *) symbol andInt : (int) amount andPrice : (double) price;
- (void) setCoreModel;

@end
