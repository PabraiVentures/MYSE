//
//  BT_SecondViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//471 lines

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

#define kSell 1
#define kBuy 1

@implementation BT_TradeViewController
@synthesize managedObjectContext;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;

- (void) viewDidLoad {
  
  [super viewDidLoad];
  self.userCache=[((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) userCache];
  // Create Login View so that the app will be granted "status_update" permission.
  //initialize profile picture
  [self initializeFBLoginView];
  //get the object context to work with stackmob data
  self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.view addGestureRecognizer:tap];
  [self updateBuyPower];
  [self updateValue];
  self.autocompleteSymbols = [[NSMutableArray alloc] initWithObjects:@"AAPL", @"GOOG", @"CSCO", @"IBM", @"YHOO", @"F", nil];
  self.autocompleteSuggestions = [[NSMutableArray alloc] init];
}

//initializeLoginView:
//uses a loginview to fetch user info. A delegate is called when the info is ready.
-(void) initializeFBLoginView{
  FBLoginView *loginview = [[FBLoginView alloc] init];
  loginview.frame = CGRectOffset(loginview.frame, 50, 50);
  loginview.hidden = YES;
  loginview.delegate = self;
  [self.view addSubview:loginview];
  [loginview sizeToFit];
  return;
}

- (void) dismissKeyboard {
  [self.amountField resignFirstResponder];
  [self.symbolField resignFirstResponder];
  if ([self.symbolField.text length] > 0) {
    NSDictionary *stockData = [self callFetchQuotes:self.symbolField.text];
    if (stockData == NULL) return;
    double lastPrice = [[stockData valueForKey:@"LastTradePriceOnly"] doubleValue];
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f", lastPrice];
    self.tickerLabel.text = [stockData valueForKey:@"symbol"];
    int maxPurchase = floor(self.userCache.coreModel.portfolio.totalcashvalue.doubleValue / lastPrice);
    self.maxPurchaseLabel.text = [NSString stringWithFormat: @"%i", maxPurchase];
    [self.stockLabel1 setHidden:false];
    [self.stockLabel2 setHidden:false];
    [self.stockLabel3 setHidden:false];
    [self.stockLabel4 setHidden:true]; //label for entering stock symbol
    [self.stockLabel5 setHidden:false];
  }
}

-(NSFetchRequest*)getRequestForUserCoreModel {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
  // query for coremodel for THIS user
  NSString* coreModelRequest=[NSString stringWithFormat:@"user == '%@'",self.userCache.userID];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
  return fetchRequest;
}

- (void) initializeCoreModel {
  [self.valueDisplay setText:@"100000.00"];
  [self.cashDisplay  setText:@"100000.00"];
  self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
  [self setCoreModel];
}

//assigns self.userCache.coreModel to the StackMob coreModel
- (void) setCoreModel {
  /********GET COREMODEL FROM STACKMOB***********/
  //download stackmob coremodel and save to local coremodel
  NSFetchRequest *fetchRequest = [self getRequestForUserCoreModel];
  //get the object context to work with stackmob data
  self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
  
  // execute the request
  [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
    @try {
      self.userCache.coreModel = (CoreModel *)[results objectAtIndex:0]; //now we can access coremodel from anywhere
      NSLog(@"succeeded setting CoreModel");
      [self updateBuyPower];
      [self updateValue];
    }
    @catch (NSException *exception) {
      [self initializeCoreModel];
    }
  } onFailure:^(NSError *error) {
    NSLog(@"There was an error! %@", error);
  }];
}

//Updates Labels on UI to display current value of portfolio in userCache
- (void) updateValue {
  double value = 0.0;
  double prc = 0.0;
  int amt = 0;
  for(CoreStock *stock in self.userCache.coreModel.portfolio.stocks) {
    prc = [[Controller currentPriceForSymbol:stock.symbol] doubleValue];
    amt = stock.amount.intValue;
    value += (prc * amt);
  }
  value += self.userCache.coreModel.portfolio.totalcashvalue.doubleValue;
  NSString *valString = [NSString stringWithFormat:@"$%.2f", value];
  [self.valueDisplay setText: valString];
}

//Updates Labels on UI to display the buying power of portfolio in userCache
- (void)updateBuyPower {
  NSString *money = [NSString stringWithFormat:@"$%.2f", self.userCache.coreModel.portfolio.totalcashvalue.floatValue];
  [self.cashDisplay setText: money];
}

/************Gets stock data from YahooFinance**********/
- (NSDictionary *) callFetchQuotes: (NSString*) stockSymbol {
  NSArray *stock = [NSArray arrayWithObjects: stockSymbol, nil];
  NSDictionary *data = [Controller fetchQuotesFor:stock];
  return data;
}

//This should be a Portfolio class method
- (CoreStock*) checkForStockInPortfolio: (NSString *) symbol andInt : (int *) amount {
  for(CoreStock* s in self.userCache.coreModel.portfolio.stocks) {
    if ([s.symbol isEqual: symbol]) {
      *amount += s.amount.intValue;
      return s;
    }
  }
  return nil;
}

//Returns purchase price of one stock and changed value of "amount" for later calulations
//Used to find average purchase price when trading a stock
- (NSMutableArray *) accountForPrevOwnedStock: (NSString *) symbol andInt : (int) amount andPrice : (double) price {
  NSNumber *theAmount = [NSNumber numberWithInt:amount];
  NSNumber *thePrice = [NSNumber numberWithDouble:price];
  NSMutableArray *amtAndPrc = [[NSMutableArray alloc] initWithObjects:theAmount, thePrice, nil];
  
  for(CoreStock* stock in self.userCache.coreModel.portfolio.stocks) {
    if ([symbol caseInsensitiveCompare: stock.symbol] == NSOrderedSame) {
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

- (IBAction)logoutButtonClicked:(id)sender { //delete token info
  [FBSession.activeSession closeAndClearTokenInformation];
}
//Delagate callback function for Facebook Data
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
  self.profilePic.profileID = user.id;
  self.loggedInUser = user;
  NSLog(@"%@-----",user);
  NSString *userName = [NSString stringWithFormat:@"%@'s Trading Floor", user.first_name];
  self.investorName.text = userName;
  [[NSUserDefaults standardUserDefaults] setObject:user.first_name forKey:@"Name"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) textFieldShouldReturn: (UITextField *)theTextField {
  if ((theTextField == self.symbolField) || (theTextField == self.amountField)) {
    [theTextField endEditing:YES];
    [self dismissKeyboard];
  }
  return YES;
}

//Confirmation alert for buying
- (void) showBuyConfirmationAlertWithAmount:(int)amount andSymbol:(NSString*)buyingSymbol andTotalPrice:(double)totalPrice {
  NSString *confirmationString = [NSString stringWithFormat:@"Are you sure you'd like to buy %i shares of %@ for $%.2f?", amount, buyingSymbol, totalPrice];
  UIAlertView *buyConfirmation = [[UIAlertView alloc] initWithTitle:@"Confirm Trade" message:confirmationString delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Confirm Trade", nil];
  buyConfirmation.tag = kBuy;
  [buyConfirmation show];
}

#pragma mark - Trading Methods

/************************BUYING**************************/

- (IBAction) buyButtonClicked:(id)sender {
  NSString *buyingSymbol;
  if([self.symbolField.text length] > 0) buyingSymbol = [self.symbolField.text uppercaseString];
  NSLog(@"buying symbol: %@", buyingSymbol);
  int amount;
  int amountForHistory;
  double totalPrice=-1;
  if([self.amountField.text length] > 0) amount = [self.amountField.text intValue];
  else amount = 0;
  amountForHistory = amount;

  totalPrice=[self getTotalBuyPriceIfPossibleWithSymbol: buyingSymbol andAmount: amount ];
  if (totalPrice==-1)return;
  [self showBuyConfirmationAlertWithAmount: amount andSymbol:buyingSymbol andTotalPrice:totalPrice];
}

-(double) getTotalBuyPriceIfPossibleWithSymbol:(NSString*)buyingSymbol andAmount: (int) amount{
  
  NSDictionary *data;
  @try {
    data = [self callFetchQuotes:buyingSymbol];
  }
  @catch (NSException *exception) {
    [self showErrorAlert:@"Try Again" andMessage:@"Stock Data Currently Not Available"];
    return -1;
  }
  NSLog(@"data: %@", data);
  NSString *myStockPrice = data[@"LastTradePriceOnly"];
  if(myStockPrice == NULL || amount == 0) [self showErrorAlert:@"Error" andMessage:@"Invalid symbol or amount"];
  else {
    reservedBuyPrice = [myStockPrice doubleValue];
    double totalPrice = reservedBuyPrice * amount;
    NSLog(@"totalcashval: %@", self.userCache.coreModel.portfolio.totalcashvalue);
    if (totalPrice > self.userCache.coreModel.portfolio.totalcashvalue.doubleValue) {
      [self showErrorAlert:@"Not enough cash!" andMessage:[NSString stringWithFormat:@"You don't have enough money to buy %i shares of %@ at %.2f.", amount, buyingSymbol, reservedBuyPrice]];
      return -1;
    }
    return totalPrice;
  }
  return -1;

}
/***CREATE CORESTOCK TO BE PLACED INTO COREMODEL.PORTFOLIO******/
- (CoreStock*) stockForCorePortfolio: (NSString*) buyingSymbol andAmount: (int) amount andPrice: (double) price {
  CoreStock* thestock = [NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:self.managedObjectContext];
  NSMutableArray *amountAndPrice = [self accountForPrevOwnedStock:buyingSymbol andInt: amount andPrice:price];
  thestock.amount = [amountAndPrice objectAtIndex:0];
  thestock.buyprice = [amountAndPrice objectAtIndex:1];
  thestock.symbol = buyingSymbol;
  [thestock setValue:[thestock assignObjectId] forKey:[thestock primaryKeyField]];
  return thestock;
}

- (void) addStockToModelWithSymbol: (NSString*)buyingSymbol andPrice:(double)price andAmount:(int)amount {
  [self.userCache addTradeEventFromStock:[CoreStock initWithSymbol:buyingSymbol AndPrice:price AndAmount:amount] withActionID: 1];
  //subtract trade value from totalcashvalue
  double cashMoney =  self.userCache.coreModel.portfolio.totalcashvalue.doubleValue - (price * amount);
  self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithDouble: cashMoney];
  CoreStock* thestock = [self stockForCorePortfolio:buyingSymbol andAmount:amount andPrice:price];
  //ADD STOCK TO COREMODEL.PORTFOLIO TO BE SAVED LATER
  [self.userCache.coreModel.portfolio addStocksObject:thestock];// the stock is now in the portfolio
  //SAVE COREMODEL TO STACKMOB
  [self.managedObjectContext saveOnSuccess:^{
    NSLog(@"You updated the model object with a new stock buy!");
  } onFailure:^(NSError *error) {
    NSLog(@"There was an error! %@", error);
  }];
}

- (void) buy {
  NSLog(@"beginning buy");
  NSString *buyingSymbol = [self.symbolField.text uppercaseString];
  int amount = [self.amountField.text intValue];
  double price = reservedBuyPrice;
  NSLog(@"totalcashvalue: %@", self.userCache.coreModel.portfolio.totalcashvalue);
  //get the model, update and send back to stackmob
  NSFetchRequest *fetchRequest = [self getRequestForUserCoreModel];
  /**********START CODE BLOCK FOR REQUEST ACTION************/
  [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
    NSManagedObject* myModel = [results objectAtIndex:0];
    self.userCache.coreModel = (CoreModel*) myModel;
    [self addStockToModelWithSymbol:buyingSymbol andPrice:price andAmount:amount];
  } onFailure:^(NSError *error) {
    NSLog(@"Error fetching: %@", error);
  }];
  [self setCoreModel];
  [self updateBuyPower];
  [self updateValue];
  for(CoreStock *s in self.userCache.coreModel.portfolio.stocks)
  {
    NSLog(@"%@ : $%.2f\tamount:%i\n", s.symbol, s.buyprice.doubleValue, s.amount.intValue);
  }
  NSLog(@"ending buy");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView.tag == kBuy && buttonIndex != 0) [self buy];
  if (alertView.tag == kSell && buttonIndex != 0) [self sell];
}

-(void)showErrorAlert:(NSString *)title andMessage: (NSString*)message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
  [alert show];
}
//Pre order Error Checking
-(BOOL) isStockValidGivenStock: (CoreStock*) stock andAmount: (int) amount andSymbol: (NSString*) symbol {
  if (stock.amount.intValue < amount) {
    [self showErrorAlert:@"Nice try!" andMessage:@"You don't own enought of this stock."];
    return false;
  }
  if (amount <= 0) {
    [self showErrorAlert:@"Invalid Amount" andMessage:@"Please enter a valid amount."];
    return false;
  }
  NSDictionary *stockData = [self callFetchQuotes:symbol];
  NSString *myStockPrice = stockData[@"LastTradePriceOnly"];
  reservedSalePrice = [myStockPrice doubleValue];
  if (reservedSalePrice <= 0) {
    [self showErrorAlert:@"Error Fetching Quote" andMessage:@"The symbol you requested returned an invalid quote. Please try again."];
    return false;
  }
  return true;
}
//Pre order Error Checking
- (bool) stockAndAmountFieldsAreValid {
  if ([self.amountField.text length] <= 0) {
    [self showErrorAlert:@"Must Enter Amount" andMessage:@"Please make sure you have entered an amount."];
    return false;
  }
  if([self.symbolField.text length] <= 0) {
    [self showErrorAlert:@"Must Enter Symbol" andMessage:@"Please make sure you have entered a symbol."];
    return false;
  }
  return true;
}

/************************SELLING**************************/
- (IBAction)sellButtonClicked:(id)sender {
  if (![self stockAndAmountFieldsAreValid]) return;
  NSInteger amount = [self.amountField.text intValue];
  NSString *symbol = [self.symbolField.text uppercaseString];
  //makes sure enough of stock is available
  for(CoreStock* stock in self.userCache.coreModel.portfolio.stocks) {
    if ([symbol caseInsensitiveCompare:stock.symbol] == NSOrderedSame) {
      if (![self isStockValidGivenStock:stock andAmount: amount andSymbol:symbol]) return;
      NSDictionary *stockData = [self callFetchQuotes:symbol];
      NSString *myStockPrice = stockData[@"LastTradePriceOnly"];
      reservedSalePrice = [myStockPrice doubleValue];
      double totalPrice = reservedSalePrice * amount;
      NSString *confirmationString = [NSString stringWithFormat:@"Are you sure you'd like to sell %i shares of %@ for $%.2f?", amount, symbol, totalPrice];
      UIAlertView *sellConfirmation = [[UIAlertView alloc] initWithTitle:@"Confirm Trade" message:confirmationString delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Confirm Trade", nil];
      sellConfirmation.tag = kSell;
      [sellConfirmation show];
      matchedSaleStock = stock;
      return;
    }
  }
  [self showErrorAlert:@"No Matching Stock!" andMessage:@"No stock was found in your portfolio with the symbol you provided. Please try again."];
}

- (void) sell {
  int amount = [self.amountField.text intValue];
  //if selling all, just delete stock from portfolio, THEN completely delete stock
  if(matchedSaleStock.amount.intValue == amount)
  {
    [self.userCache.coreModel.portfolio removeStocksObject:matchedSaleStock];
    [self.managedObjectContext deleteObject:matchedSaleStock];
  }
  else matchedSaleStock.amount = [NSNumber numberWithInt:(matchedSaleStock.amount.intValue - amount)]; //only selling a portion of your chosen stock
  self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithDouble: (self.userCache.coreModel.portfolio.totalcashvalue.doubleValue + reservedSalePrice * amount)];
  
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

/*Put anything that starts with this substring into the autocompleteSuggestions array.
 *The items in this array is what will show up in the table view.*/
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
  [self.autocompleteSuggestions removeAllObjects];
  for(NSString *curString in self.autocompleteSymbols) {
    NSRange substringRange = [curString rangeOfString:substring];
    if (substringRange.location == 0) [self.autocompleteSuggestions addObject:curString];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  UITableViewCell *cell = nil;
  static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
  cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
  if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
  cell.textLabel.text = [self.autocompleteSuggestions objectAtIndex:indexPath.row];
  return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  self.symbolField.text = selectedCell.textLabel.text;
}

@end