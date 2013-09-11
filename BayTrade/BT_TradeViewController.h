//
//  BT_SecondViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import <FacebookSDK/FacebookSDK.h>

@interface BT_TradeViewController : UIViewController <FBLoginViewDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    double reservedBuyPrice;
    double reservedSalePrice;
    NSString *saleSymbol;
    CoreStock *matchedSaleStock;
}

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (nonatomic, strong) Cache *userCache;

@property (weak, nonatomic) IBOutlet UILabel *valueDisplay;
@property (weak, nonatomic) IBOutlet UILabel *cashDisplay;
@property (weak, nonatomic) IBOutlet UITextField *symbolField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *investorName;

@property (nonatomic, retain) NSMutableArray *autocompleteSuggestions;
@property (nonatomic, retain) NSMutableArray *autocompleteSymbols;
@property (nonatomic, retain) UITableView *autocompleteTableView;

- (IBAction)buyButtonClicked:(id)sender;
- (IBAction)sellButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
- (NSMutableArray *) accountForPrevOwnedStock: (NSString *) symbol andInt: (int) amount andPrice: (double) price;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (void) setCoreModel;

@end