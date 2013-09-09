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
#import "Model.h"
#import "StackMob.h"
#import <CoreData/CoreData.h>
#import "CoreModel.h"
#import "CoreStock.h"
#import "CorePortfolio.h"
#import "CoreTradeEvent.h"
#import <FacebookSDK/FacebookSDK.h>
@interface BT_TradeViewController ()

@end

@implementation BT_TradeViewController
@synthesize managedObjectContext;
//@synthesize labelFirstName = _labelFirstName;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.userModel=((BT_TabBarController*)(self.tabBarController)).userModel;
    
    // Create Login View so that the app will be granted "status_update" permission. 
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.frame = CGRectOffset(loginview.frame, 50, 50);
    loginview.hidden = YES;
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
    
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self setCoreModel];
    [self updateOwnedStocks];
    [self updateBuyPower];
    [self updateValue];
}

- (void) dismissKeyboard {
    [self.amountField resignFirstResponder];
    [self.symbolField resignFirstResponder];
    [self setCoreModel];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//assigns self.userModel.coreModel to the StackMob coreModel
//AND updates the display
- (void) setCoreModel
{
    /********GET COREMODEL FROM STACKMOB***********/
    //download stackmob coremodel and save to local coremodel
    //get the model, update and send back to stackmob
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    
    // query for coremodel for THIS user
    NSString* coreModelRequest=[NSString stringWithFormat:@"user == '%@'",self.userModel.userID];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
    
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    // execute the request
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
    //NSLog(@"????%@",results);
    
    BOOL needsUpdate = YES;
        NSLog(@"SM download result: %@",results);
    @try {
        NSManagedObject* myModel=[results objectAtIndex:0];
        self.userModel.coreModel = (CoreModel *) myModel; //now we can access coremodel from anywhere
        NSLog(@"self.coremodel: %@", self.userModel.coreModel);
        NSLog(@"self.coremodel.portfolio: %@", self.userModel.coreModel.portfolio);
        self.userModel.modelPort=((CoreModel*) myModel).portfolio;
        NSLog(@"self.coremodel.portfolio.totalcashval: %@", self.userModel.coreModel.portfolio.totalcashvalue);
    }
    @catch (NSException *exception) {
        [self.valueDisplay setText:@"100000.00"];
        [self.cashDisplay setText:@"100000.00"];
        self.userModel.modelPort.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
        needsUpdate = NO;
    }
    
    if(needsUpdate)
    {
        /***Updates display HERE now***/
        [self updateBuyPower];
        [self updateValue];
    }
        
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
    /********DONE GETTING COREMODEL FROM STACKMOB***********/
}

/************************BUYING**************************/
/************************BUYING**************************/
/************************BUYING**************************/
/************************BUYING**************************/

- (IBAction) buyButtonClicked:(id)sender
{
    NSLog(@"beginning buybuttonclicked");
    //assign self.userModel.coreModel to the StackMob coreModel
    [self setCoreModel];
    NSLog(@"finished setcoremodel");
    NSString *buyingSymbol = [NSString string];
    if([self.symbolField.text length] > 0) buyingSymbol = self.symbolField.text;
    else buyingSymbol = NULL;
    int amount;
    int amountForHistory = 0;
    if([self.amountField.text length] > 0) amount = [self.amountField.text intValue];
    else amount = 0;
    amountForHistory = amount;
    NSDictionary *data;
    @try {
        data = [self callFetchQuotes:buyingSymbol];
        NSLog(@"finished calling fetch quotes");
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!"
                                                        message:@"Can't get data!"
                                                       delegate:self cancelButtonTitle:@"Fine..."
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSLog(@"data: %@", data);
    NSString *myStockPrice = data[@"Open"];
    
    double price = [myStockPrice doubleValue];
    
    //if the symbol didn't get results...
    if(myStockPrice == NULL || amount == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold up!"
                                                        message:@"Invalid symbol or amount"
                                                       delegate:self cancelButtonTitle:@"Got it"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
    else
    {
        NSLog(@"beginning else");
        double totalPrice = price * amount;
        //double debugPrice = self.userModel.coreModel.portfolio.cashvalue.doubleValue;
        //if you can buy the stock
        NSLog(@"totalcashvalue: %@", self.userModel.modelPort.totalcashvalue);
        NSLog(@"totalcashvalue in modelport: %@", self.userModel.modelPort.totalcashvalue);
        
        if (totalPrice <= self.userModel.modelPort.totalcashvalue.doubleValue)
        {
            self.userModel.modelPort.totalcashvalue = [NSNumber numberWithFloat: self.userModel.modelPort.totalcashvalue.doubleValue - totalPrice];
            
            //get the model, update and send back to stackmob
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
            // query for coremodel for THIS user
            NSString* getRightUser=[ NSString stringWithFormat:@"user == '%@'",self.userModel.userID ];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightUser]];
            
            
            /**********START CODE BLOCK FOR REQUEST ACTION************/
            [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
                NSLog(@"!!!!!%@",results);
                NSManagedObject* myModel=[results objectAtIndex:0];
                self.userModel.coreModel= (CoreModel* ) myModel;
                [self.userModel updateHistory:[CoreStock initWithSymbol:buyingSymbol AndPrice:price AndAmount:amount] andAmount: amountForHistory andID:1];
                
                
                //subtract money from purchase
                double cashMoney =  self.userModel.coreModel.portfolio.totalcashvalue.doubleValue - (price * amount);
                self.userModel.coreModel.portfolio.totalcashvalue = [NSNumber numberWithFloat: cashMoney];
                NSMutableArray *amountAndPrice = [self accountForPrevOwnedStock:buyingSymbol andInt: amount andPrice:price];
                
                /***CREATE CORESTOCK TO BE PLACED INTO COREMODEL.PORTFOLIO******/
                CoreStock* thestock=[NSEntityDescription insertNewObjectForEntityForName:@"CoreStock" inManagedObjectContext:self.managedObjectContext];
                //NSNumber* theamt=[NSNumber numberWithInt:amount];
                thestock.amount = [amountAndPrice objectAtIndex:0];
                thestock.buyprice=[amountAndPrice objectAtIndex:1];
                thestock.symbol=buyingSymbol;
                NSLog(@"thestock primaryKeyField: %@", [thestock primaryKeyField]);
                NSLog(@"thestock assignobjectid: %@", [thestock assignObjectId]);
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
            
            [self setCoreModel];
        }
        else //if you don't have enough cash
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get a Job!"
                                                            message:[NSString stringWithFormat:@"You don't have enough money to buy %i shares of %@ at %f.", amount, buyingSymbol, price]
                                                           delegate:self cancelButtonTitle:@"Got it"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }
        for(CoreStock *s in self.userModel.modelPort.stocks)
        {
            NSLog(@"%@ : $%.2f\tamount:%i\n", s.symbol, s.openprice.doubleValue, s.amount.intValue);
        }
    }
    NSLog(@"ending buybuttonclicked");
}

/************************SELLING**************************/
/************************SELLING**************************/
/************************SELLING**************************/
/************************SELLING**************************/

- (IBAction)SellButtonClicked:(id)sender
{
    //assign self.userModel.coreModel to the StackMob coreModel
    [self setCoreModel];
    
    NSString *sellingSymbol;
    if([self.symbolField.text length] > 0)
        sellingSymbol = self.symbolField.text;
    else sellingSymbol = NULL;
    
    NSInteger sellingAmount;
    if([self.amountField.text length] > 0)
        sellingAmount = [self.amountField.text intValue];
    else
        sellingAmount = 0;
    
    [self sellIfCan:sellingSymbol andInt:sellingAmount];
    [self setCoreModel];
}


//Only works for buying
- (void) updateValue
{
    double value = 0.0;
    double prc = 0.0;
    int amt = 0;
    for(CoreStock *stock in self.userModel.modelPort.stocks)
    {
        prc = stock.buyprice.doubleValue;
        amt = stock.amount.intValue;
        value += (prc * amt);
    }
    NSLog(@"updating value");
    NSLog(@"stock value = %.2f", value);
    
    value += self.userModel.modelPort.totalcashvalue.doubleValue;
    
    NSLog(@"total value = %.2f", value);
    
    NSString *valString = [NSString stringWithFormat:@"$%.2f", value];
    [self.valueDisplay setText: valString];
}   

- (void)updateBuyPower
{
    NSLog(@"updating buy power");
    NSString *money = [NSString stringWithFormat:@"$%.2f", self.userModel.modelPort.totalcashvalue.floatValue];
    [self.cashDisplay setText: money];
}

/************Gets stock data from YahooFinance**********/
- (NSDictionary *) callFetchQuotes : (NSString*) stockSymbol
{
    NSArray *stock = [NSArray arrayWithObjects: stockSymbol, nil];
    NSLog(@"stock array: %@", stock);
    NSDictionary *data = [Controller fetchQuotesFor:stock];
    return data;
}


- (CoreStock* ) checkForStockInPortfolio : (NSString *) symbol andInt : (int *) amount
{
    //Stock *moreStock = NULL;
    
    CoreStock* matching = NULL;
    for(CoreStock* s in self.userModel.modelPort.stocks)
    {
        if ([s.symbol isEqual: symbol])
        {
            matching = s;
            *amount += s.amount.intValue;
            //moreStock = [Stock initWithSymbol:s.symbol AndPrice:s.openPrice AndAmount:s.amount];
            return s;
            break;
        }
    }
    return matching;
}

//Returns purchase price of one stock and changed value of "amount" for later calulations
- (NSMutableArray *) accountForPrevOwnedStock : (NSString *) symbol andInt : (int) amount andPrice : (double) price
{
    NSNumber *theAmount = [NSNumber numberWithInt:amount];
    NSNumber *thePrice = [NSNumber numberWithDouble:price];
    NSMutableArray *amtAndPrc = [[NSMutableArray alloc] initWithObjects:theAmount, thePrice, nil];
    
    for(CoreStock* stock in self.userModel.coreModel.portfolio.stocks)
    {
        //Stock* s = [self.userModel.coreModel.portfolio.stocks objectAtIndex:i];
        if ([symbol isEqual: stock.symbol])
        {
            double newvalue =  price * amount + (stock.amount.intValue * stock.buyprice.doubleValue);
            NSNumber *newAmount= [NSNumber numberWithInt:(amount + stock.amount.intValue)];
            NSNumber *newPurchasedPrice= [NSNumber numberWithDouble:(newvalue / newAmount.doubleValue)];
            NSMutableArray *newAmtPrice = [[NSMutableArray alloc] initWithObjects:newAmount, newPurchasedPrice, nil];
            [self.userModel.coreModel.portfolio removeStocksObject:stock];
            [self.managedObjectContext deleteObject:stock];
            return newAmtPrice;
        }
    }
    return amtAndPrc;
}


/**
 * Returns purchase price of one stock and changed value of "amount" for later calulations
 */
- (BOOL) sellIfCan : (NSString *) symbol andInt : (int) amount
{
    NSNumber *theAmountToSell = [NSNumber numberWithInt:amount];
    
    for(CoreStock* stock in self.userModel.coreModel.portfolio.stocks)
    {
        if ([symbol isEqual: stock.symbol])
        {
            NSLog(@"The stock amount is %@", stock.amount);
            if(stock.amount.intValue < theAmountToSell.intValue)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"You don't own enought of this stock" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return NO;//<-might cause errors
            }
            
            //if selling all, just delete stock from portfolio, THEN completely delete stock
            else if(stock.amount.intValue == theAmountToSell.intValue)
            {
                [self.userModel.coreModel.portfolio removeStocksObject:stock];
                [self.managedObjectContext deleteObject:stock];
            }
            else //only selling a portion of your chosen stock
            {
                //edit # of shares
                stock.amount = [NSNumber numberWithInt:(stock.amount.intValue - theAmountToSell.intValue)];
            }
            NSDictionary *sellData = [self callFetchQuotes:symbol];
            
            NSString *myStockPrice = sellData[@"Open"];
            double sellPrice = [myStockPrice doubleValue];
            
            self.userModel.coreModel.portfolio.totalcashvalue =
          [NSNumber numberWithFloat:   (self.userModel.coreModel.portfolio.totalcashvalue.doubleValue+sellPrice * theAmountToSell.intValue)];
            
            /***** CREATE LOCAL STOCK TO SAVE IN HISTORY *****/
            CoreStock *hStock = [[CoreStock alloc] init];
            [hStock setAmount: theAmountToSell];
            hStock.symbol = symbol;
            hStock.openprice = [NSNumber numberWithDouble: sellPrice];
            /***** CREATE LOCAL STOCK TO SAVE IN HISTORY *****/
            
            [self.userModel updateHistory:hStock andAmount: theAmountToSell.intValue andID:0];
            
            //SAVE COREMODEL TO STACKMOB
            [self.managedObjectContext saveOnSuccess:^{
                NSLog(@"You updated the model object by selling a stock!");
            } onFailure:^(NSError *error) {
                NSLog(@"There was an error! %@", error);
            }];
            return YES;
        }//if
    }//for
    
    //if outside, then you don't own the stock
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"You don't own enought of this stock" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    return NO;
}



/**
 *  Updates stock data in stackmob with current Stock Prices
 */
- (void) updateOwnedStocks {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreStock"];//get the model, update and send back to stackmob
    
    NSString* getOwnedStocks= [NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userModel.userID];// query for coremodel for THIS user
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getOwnedStocks]];
    
    
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *ownedStocks) {
        NSLog(@"owned stocks:%@",ownedStocks);
        
        NSMutableArray *ownedSymbols = [[NSMutableArray alloc] init];//create array of symbols to pass to Yahoo! Finance
        for(NSManagedObject* stock in ownedStocks)
        {
            CoreStock *ownedStock = (CoreStock *) stock;
            [ownedSymbols addObject:ownedStock.symbol];
        }
        
        if([ownedSymbols count] == 0) {
            NSLog(@"No owned symbols");
            return;
        }
        
        //API call to Yahoo! Finance for all stocks in your portfolio
        NSDictionary *data = [[NSDictionary dictionary] init];
        data = [Controller fetchQuotesFor:ownedSymbols];
        
        NSLog(@"fetched data from controller: %@", data);
        
        NSError *error;
        NSData *jsonData;
        
        @try {
            jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Problem" message:@"Try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        NSString *jsonString;
        NSArray* jsonArray;
        NSMutableArray *dictArray = [[NSMutableArray alloc] init];
        //int idx = 0;
        if (!jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //NSLog(@"jsonString: %@", jsonString);
            jsonArray = [jsonString componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"{}[]\n,"]];
            //NSLog(@"jsonArray: %@", jsonArray);
            
            //loops through results of API call and create 1 dictionary per stock
            //then puts each dictionary in an array
            for (NSString *currentLine in jsonArray) {
                //NSLog(@"looping");
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                if ([currentLine rangeOfString:@"BidRealtime"].location != NSNotFound)
                {
                    NSArray *components = [currentLine componentsSeparatedByString:@"\"BidRealtime\" : "];
                    NSString *bidRealTime = (NSString*)[components objectAtIndex:1];
                    bidRealTime = [bidRealTime stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [dict setObject: bidRealTime forKey: @"BidRealTime"]; //add brt price to dict in array
                }
                if ([currentLine rangeOfString:@"Open"].location != NSNotFound)
                {
                    NSArray *components = [currentLine componentsSeparatedByString:@"\"Open\" : "];
                    NSString *open = @"error";
                    if ([components count] >= 1) {
                        open = (NSString*)[components objectAtIndex:1];
                    }
                    open = [open stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [dict setObject: open forKey: @"Open"]; //add brt price to dict in array
                }
                if ([currentLine rangeOfString:@"symbol"].location != NSNotFound)
                {
                    NSArray *components = [currentLine componentsSeparatedByString:@"\"symbol\" : "];
                    NSString *symbol = (NSString* )[components objectAtIndex:1];
                    symbol = [symbol stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [dict setObject: symbol forKey: @"symbol"]; //add brt price to dict in array
                }
                if ([dict count] >= 1) {
                    [dictArray addObject:dict];
                }
            }
        }
        NSLog(@"done looping");
        NSLog(@"dictArray: %@", dictArray);
        
        //loop through all stocks and update with bidRealTime values
        for(CoreStock* stock in self.userModel.coreModel.portfolio.stocks)
        {
            NSLog(@"looping through stocks");
            NSLog(@"%@", stock.symbol);
            for (int j = 0; j < [dictArray count]; j++) {
                //NSLog(@"looping through idx");
                NSString *sym = [((NSMutableDictionary *)[dictArray objectAtIndex:j]) objectForKey:@"symbol"];
                if ([sym isEqual: stock.symbol])
                {
                    NSLog(@"added symbol %@ = %@", sym, stock.symbol);
                    NSString *curPrice = [((NSMutableDictionary *)[dictArray objectAtIndex:j]) objectForKey:@"BidRealTime"];
                    
                    NSString *opPrice = [((NSMutableDictionary *)[dictArray objectAtIndex:j]) objectForKey:@"Open"];
                    
                    stock.currentprice = [NSNumber numberWithDouble:curPrice.doubleValue];
                    stock.openprice = [NSNumber numberWithDouble:opPrice.doubleValue];
                    int amount = stock.amount.intValue;
                    double totalValue = curPrice.doubleValue * amount;
                    stock.totalvalue = [NSNumber numberWithDouble:totalValue];
                    break;
                }
            }
        }
        //ADDING STOCK TO COREMODEL.PORTFOLIO TO BE SAVED LATER
        //[((Coremodel*)(myModel)).portfolio addStocksObject:thestock];// the stock is now in the portfolio
        //SAVE COREMODEL TO STACKMOB
        
        [self.managedObjectContext saveOnSuccess:^{
            NSLog(@"Stocks updated successfully!");
        } onFailure:^(NSError *error) {
            NSLog(@"There was an error! %@", error);
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

//takes JSON string of stock data, parses and updates the data to be saved into stackmob
- (void) updatePrices : (NSString *) jsonString
{
    
}

- (IBAction)logoutButtonClicked:(id)sender {
    //delete token info
    [FBSession.activeSession closeAndClearTokenInformation];
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    //self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
    NSString *userName = [NSString stringWithFormat:@"%@'s Trading Floor", user.first_name];
    self.investorName.text = userName;
}

- (BOOL) textFieldShouldReturn: (UITextField *)theTextField
{
    if ((theTextField == self.symbolField) || (theTextField == self.amountField)) {
        [theTextField endEditing:YES];
    }
    return YES;
}
@end