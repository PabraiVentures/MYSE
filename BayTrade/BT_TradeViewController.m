//
//  BT_SecondViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_TradeViewController.h"
#import "BT_TabBarController.h"
#import "BT_AppDelegate.h"
#import "Controller.h"
#import "Cache.h"
#import "StackMob.h"
#import <CoreData/CoreData.h>
#import "CoreModel.h"
#import "CoreStock.h"
#import "CorePortfolio.h"
#import <FacebookSDK/FacebookSDK.h>

@interface BT_TradeViewController ()

@end

@implementation BT_TradeViewController
@synthesize managedObjectContext;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
    
    // Create Login View so that the app will be granted "status_update" permission. 
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.frame = CGRectOffset(loginview.frame, 50, 50);
    loginview.hidden = YES;
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    [loginview sizeToFit];
    
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self performSelector:@selector(setCoreModel) withObject:nil afterDelay:0.5];
    
    self.autocompleteSymbols = [[NSMutableArray alloc] initWithObjects:@"AAPL", @"GOOG", @"CSCO", @"IBM", @"YHOO", @"A",@"F", nil];
    self.autocompleteSuggestions = [[NSMutableArray alloc] init];
}

- (void) dismissKeyboard
{
    [self.amountField resignFirstResponder];
    [self.symbolField resignFirstResponder];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//assigns self.userCache.coreModel to the StackMob coreModel
- (void) setCoreModel
{
    /********GET COREMODEL FROM STACKMOB***********/
    //download stackmob coremodel and save to local coremodel
    //get the model, update and send back to stackmob
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    
    // query for coremodel for THIS user
    NSString* coreModelRequest=[NSString stringWithFormat:@"user == '%@'",self.userCache.userID];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
    
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    // execute the request
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        BOOL needsUpdate = YES;
        @try {
            NSManagedObject* myModel=[results objectAtIndex:0];
            self.userCache.coreModel = (CoreModel *) myModel; //now we can access coremodel from anywhere
            NSLog(@"succeeded setting CoreModel");
        }
        @catch (NSException *exception) {
            [self.valueDisplay setText:@"100000.00"];
            [self.cashDisplay  setText:@"100000.00"];
            self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
            [self setCoreModel];
            needsUpdate = NO;
        }
        if(needsUpdate)
        {
            [self updateBuyPower];
            [self updateValue];
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
    /********DONE GETTING COREMODEL FROM STACKMOB***********/
}

//Only works for buying
- (void) updateValue
{
    double value = 0.0;
    double prc = 0.0;
    int amt = 0;
    for(CoreStock *stock in self.userCache.coreModel.portfolio.stocks)
    {
        prc = [[Controller currentPriceForSymbol:stock.symbol] doubleValue];
        amt = stock.amount.intValue;
        value += (prc * amt);
    }
    value += self.userCache.coreModel.portfolio.totalcashvalue.doubleValue;
    
    NSString *valString = [NSString stringWithFormat:@"$%.2f", value];
    [self.valueDisplay setText: valString];
}   

- (void)updateBuyPower
{
    NSString *money = [NSString stringWithFormat:@"$%.2f", self.userCache.coreModel.portfolio.totalcashvalue.floatValue];
    [self.cashDisplay setText: money];
}

/************Gets stock data from YahooFinance**********/
- (NSDictionary *) callFetchQuotes: (NSString*) stockSymbol
{
    NSArray *stock = [NSArray arrayWithObjects: stockSymbol, nil];
    NSDictionary *data = [Controller fetchQuotesFor:stock];
    return data;
}

- (CoreStock*) checkForStockInPortfolio: (NSString *) symbol andInt : (int *) amount
{
    for(CoreStock* s in self.userCache.coreModel.portfolio.stocks)
    {
        if ([s.symbol isEqual: symbol])
        {
            *amount += s.amount.intValue;
            return s;
        }
    }
    return nil;
}

//Returns purchase price of one stock and changed value of "amount" for later calulations
- (NSMutableArray *) accountForPrevOwnedStock: (NSString *) symbol andInt : (int) amount andPrice : (double) price
{
    NSNumber *theAmount = [NSNumber numberWithInt:amount];
    NSNumber *thePrice = [NSNumber numberWithDouble:price];
    NSMutableArray *amtAndPrc = [[NSMutableArray alloc] initWithObjects:theAmount, thePrice, nil];
    
    for(CoreStock* stock in self.userCache.coreModel.portfolio.stocks)
    {
        if ([symbol isEqual: stock.symbol])
        {
            double newvalue =  price * amount + (stock.amount.intValue * stock.buyprice.doubleValue);
            NSNumber *newAmount = [NSNumber numberWithInt:(amount + stock.amount.intValue)];
            NSNumber *newPurchasedPrice = [NSNumber numberWithDouble:(newvalue / newAmount.doubleValue)];
            NSMutableArray *newAmtPrice = [[NSMutableArray alloc] initWithObjects:newAmount, newPurchasedPrice, nil];
            [self.userCache.coreModel.portfolio removeStocksObject:stock];
            [self.managedObjectContext deleteObject:stock];
            return newAmtPrice;
        }
    }
    return amtAndPrc;
}

- (IBAction)logoutButtonClicked:(id)sender {
    //delete token info
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
    NSString *userName = [NSString stringWithFormat:@"%@'s Trading Floor", user.first_name];
    self.investorName.text = userName;
    [[NSUserDefaults standardUserDefaults] setObject:user.first_name forKey:@"Name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) textFieldShouldReturn: (UITextField *)theTextField
{
    if ((theTextField == self.symbolField) || (theTextField == self.amountField)) {
        [theTextField endEditing:YES];
    }
    return YES;
}

#pragma mark - Trading Methods

/************************BUYING**************************/

- (IBAction) buyButtonClicked:(id)sender
{
    //[self setCoreModel];
    NSString *buyingSymbol;
    if([self.symbolField.text length] > 0) buyingSymbol = self.symbolField.text;
    NSLog(@"buying symbol: %@", buyingSymbol);
    int amount;
    int amountForHistory;
    if([self.amountField.text length] > 0) amount = [self.amountField.text intValue];
    amountForHistory = amount;
    NSDictionary *data;
    @try {
        data = [self callFetchQuotes:buyingSymbol];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!"
                                                        message:@"Can't get data!"
                                                       delegate:self cancelButtonTitle:@"Okay."
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSLog(@"data: %@", data);
    NSString *myStockPrice = data[@"LastTradePriceOnly"];
    
    double price = [myStockPrice doubleValue];
    reservedBuyPrice = price;
    double totalPrice = price * amount;
    
    //if the symbol didn't get results...
    if(myStockPrice == NULL || amount == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold up!" message:@"Invalid symbol or amount" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSLog(@"totalcashval: %@", self.userCache.coreModel.portfolio.totalcashvalue);
        if (totalPrice <= self.userCache.coreModel.portfolio.totalcashvalue.doubleValue)
        {
            NSString *confirmationString = [NSString stringWithFormat:@"Are you sure you'd like to buy %i shares of %@ for %.2f?", amount, buyingSymbol, totalPrice];
            
            UIAlertView *buyConfirmation = [[UIAlertView alloc] initWithTitle:@"Confirm Trade" message:confirmationString delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Confirm Trade", nil];
            buyConfirmation.tag = 0;
            [buyConfirmation show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough cash!" message:[NSString stringWithFormat:@"You don't have enough money to buy %i shares of %@ at %.2f.", amount, buyingSymbol, price] delegate:nil cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void) buy
{
    NSLog(@"beginning buy");
    //assign self.userModel.coreModel to the StackMob coreModel
    //[self setCoreModel];
    NSString *buyingSymbol = self.symbolField.text;
    int amount = [self.amountField.text intValue];
    double price = reservedBuyPrice;
    
    NSLog(@"totalcashvalue: %@", self.userCache.coreModel.portfolio.totalcashvalue);
    
    //get the model, update and send back to stackmob
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    // query for coremodel for THIS user
    NSString* getRightUser = [NSString stringWithFormat:@"user == '%@'",self.userCache.userID ];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightUser]];
    
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        NSManagedObject* myModel=[results objectAtIndex:0];
        self.userCache.coreModel = (CoreModel*) myModel;
        [self.userCache addTradeEventFromStock:[CoreStock initWithSymbol:buyingSymbol AndPrice:price AndAmount:amount] withActionID: 1];
        
        //subtract trade value from totalcashvalue
        double cashMoney =  self.userCache.coreModel.portfolio.totalcashvalue.doubleValue - (price * amount);
        self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithDouble: cashMoney];
        NSMutableArray *amountAndPrice = [self accountForPrevOwnedStock:buyingSymbol andInt: amount andPrice:price];
        
        /***CREATE CORESTOCK TO BE PLACED INTO COREMODEL.PORTFOLIO******/
        CoreStock* thestock=[NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:self.managedObjectContext];
        thestock.amount = [amountAndPrice objectAtIndex:0];
        thestock.buyprice = [amountAndPrice objectAtIndex:1];
        thestock.symbol = buyingSymbol;
        [thestock setValue:[thestock assignObjectId] forKey:[thestock primaryKeyField]];
        /***DONE CREATING CORESTOCK TO BE PLACED INTO COREMODEL.PORTFOLIO******/
        
        //ADDING STOCK TO COREMODEL.PORTFOLIO TO BE SAVED LATER
        [((CoreModel*)(myModel)).portfolio addStocksObject:thestock];// the stock is now in the portfolio
        //SAVE COREMODEL TO STACKMOB
        [self.managedObjectContext saveOnSuccess:^{
            NSLog(@"You updated the model object with a new stock buy!");
        } onFailure:^(NSError *error) {
            NSLog(@"There was an error! %@", error);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
    
    //[self setCoreModel];
    [self updateBuyPower];
    [self updateValue];
    for(CoreStock *s in self.userCache.coreModel.portfolio.stocks)
    {
        NSLog(@"%@ : $%.2f\tamount:%i\n", s.symbol, s.buyprice.doubleValue, s.amount.intValue);
    }
    NSLog(@"ending buy");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex != 0){
        [self buy];
    }
    else if (alertView.tag == 1 && buttonIndex !=0) {
        [self sell];
    }
}

/************************SELLING**************************/

- (IBAction)sellButtonClicked:(id)sender
{
    //assign self.userModel.coreModel to the StackMob coreModel
    //[self setCoreModel];
    
    NSInteger amount;
    if([self.amountField.text length] > 0)
        amount = [self.amountField.text intValue];
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Must Enter Amount" message:@"Please make sure you have entered an amount." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString *symbol;
    if([self.symbolField.text length] > 0)
        symbol = self.symbolField.text;
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Must Enter Symbol" message:@"Please make sure you have entered a symbol." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //makes sure enough of stock is available
    for(CoreStock* stock in self.userCache.coreModel.portfolio.stocks) {
        if ([symbol caseInsensitiveCompare:stock.symbol] == NSOrderedSame) {
            if (stock.amount.intValue < amount) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"You don't own enought of this stock." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else {
                if (amount <= 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Please enter a valid amount." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];
                    return;
                }
                NSDictionary *stockData = [self callFetchQuotes:symbol];
                NSString *myStockPrice = stockData[@"LastTradePriceOnly"];
                reservedSalePrice = [myStockPrice doubleValue];
                
                if (reservedSalePrice <= 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Fetching Quote" message:@"The symbol you requested returned an invalid quote. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];
                    return;
                }
                double totalPrice = reservedSalePrice * amount;
                NSString *confirmationString = [NSString stringWithFormat:@"Are you sure you'd like to sell %i shares of %@ for $%.2f?", amount, symbol, totalPrice];
                
                UIAlertView *sellConfirmation = [[UIAlertView alloc] initWithTitle:@"Confirm Trade" message:confirmationString delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Confirm Trade", nil];
                sellConfirmation.tag = 1;
                [sellConfirmation show];
                matchedSaleStock = stock;
                return;
            }
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Matching Stock" message:@"No stock was found in your portfolio with the symbol you provided. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

- (void) sell
{
    int amount = [self.amountField.text intValue];
    //if selling all, just delete stock from portfolio, THEN completely delete stock
    if(matchedSaleStock.amount.intValue == amount)
    {
        [self.userCache.coreModel.portfolio removeStocksObject:matchedSaleStock];
        [self.managedObjectContext deleteObject:matchedSaleStock];
    }
    else //only selling a portion of your chosen stock
    {
        matchedSaleStock.amount = [NSNumber numberWithInt:(matchedSaleStock.amount.intValue - amount)];
    }
    
    self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithDouble: (self.userCache.coreModel.portfolio.totalcashvalue.doubleValue+ reservedSalePrice * amount)];
    
    [self.userCache addTradeEventFromStock:[CoreStock initWithSymbol:matchedSaleStock.symbol AndPrice:reservedSalePrice AndAmount:amount] withActionID: 0];
    
    //SAVE COREMODEL TO STACKMOB
    [self.managedObjectContext saveOnSuccess:^{
        NSLog(@"Updated model by selling stock!");
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
    [self updateBuyPower];
    [self updateValue];
}

#pragma mark AutoComplete methods


    // Put anything that starts with this substring into the autocompleteSuggestions array
    // The items in this array is what will show up in the table view
    [self.autocompleteSuggestions removeAllObjects];
    for(NSString *curString in self.autocompleteSymbols) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.autocompleteSuggestions addObject:curString];
        }
    }
    [self.autocompleteTableView reloadData];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.autocompleteTableView.hidden = NO;
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return self.autocompleteSymbols.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell.textLabel.text = [self.autocompleteSuggestions objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.symbolField.text = selectedCell.textLabel.text;
   
    
}






@end