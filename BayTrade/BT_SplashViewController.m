//
//  BT_SplashViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_SplashViewController.h"
#import "BT_AppDelegate.h"
#import "StackMob.h"
#import <CoreData/CoreData.h>
#import "Controller.h"
#import "BT_GraphAnimationView.h"
#import "BT_TradeViewController.h"
@interface BT_SplashViewController ()

@end

@implementation BT_SplashViewController

@synthesize progressIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// animation here
    //perform network fns on background thread
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    BT_AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    self.userCache =[appDelegate userCache];
    [self performSelector:@selector(delaySetCoreModel) withObject:nil afterDelay:1.0];
    BT_GraphAnimationView *loadingAnimationView = [[BT_GraphAnimationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    [self.view addSubview:loadingAnimationView];
}

- (void) delaySetCoreModel
{
    [self performSelectorInBackground:@selector(loadTickerData) withObject:nil];
    [self performSelectorInBackground:@selector(setCoreModel) withObject:nil];
}

#pragma mark - Custom Download Threads

-(void)downloadCurrentStocksInfo
{
    NSLog(@"downloading current stocks info");
    float stockNum = 1; //TODO
    float numStocks = self.userCache.coreModel.portfolio.stocks.count-1; //TODO
  int loopcount;
  NSMutableDictionary *currentPrices;
  NSMutableArray* tickers= [[NSMutableArray alloc] init];

  @try{
      
        for (CoreStock *stock in self.userCache.coreModel.portfolio.stocks) {
          loopcount=0;
            stockNum++; // roll into single YQL request?
          [tickers addObject:stock.symbol];//add stock ticker to array
          

        
          
                      }
      NSNumber *progPercent = [NSNumber numberWithFloat:(1)];

          NSLog(@"fetching initial stocks");
      currentPrices=[[Controller fetchQuotesFor:tickers] mutableCopy];

            [self performSelectorOnMainThread:@selector(setProgressStatus:) withObject:progPercent waitUntilDone:YES];
    }
    @catch(NSException* e){
        NSLog(@"Error spashsscreen loading data\n%@", e);
    
        }

  [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
  [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];

}

- (void) done
{
    NSLog(@"load success; going to trade view");
    [self performSegueWithIdentifier:@"loadSuccess" sender:nil];
}

- (void) setCoreModel
{
    NSLog(@"Splashview: setting core model");
    /********GET COREMODEL FROM STACKMOB***********/
    //download stackmob coremodel and save to local coremodel
    //get the model, update and send back to stackmob
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreModel"];
    
    // query for coremodel for THIS user
    NSString* coreModelRequest=[NSString stringWithFormat:@"user == '%@'", [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:coreModelRequest]];
    
    //get the object context to work with stackmob data
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    
    // execute the request
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        @try {
            NSManagedObject* myModel = [results objectAtIndex:0];
            self.userCache.coreModel = (CoreModel *) myModel;
            [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setUserCache:self.userCache];//now we can access coremodel from anywhere
            [self performSelectorInBackground:@selector(downloadCurrentStocksInfo) withObject:nil];
        }
        @catch (NSException *exception) {
            self.userCache.coreModel.portfolio.totalcashvalue = [NSNumber numberWithFloat: 100000.0];
            NSLog(@"repeating setcoremodel; exception: %@", exception);
            [self setCoreModel];
        }
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
}

-(void) loadTickerData
{
/*    NSMutableArray *tickerItems = [[NSMutableArray alloc] init];
    
    NSArray *tickers = [NSArray arrayWithObjects:@"AAPL", @"GOOG", @"MSFT", @"BA", @"F", nil];
  //PROBLEM FIGURED OUT. SOLUTION BELOW. STUDYING FOR A CERTFICIATION TOMORROW./// -----------<            JUST NEED TO CREATE PROPER DICT HERE... WELL AFTER FETCHING.
  
  [Controller fetchQuotesFor:tickers];
  
  //example is a dictionary. it has Symbol, Positive, PercentChange, CurrentPrice
//    for (NSString *ticker in tickers) { //needs to be for each stock returned from fetchquotes set  all of the example dictionary's values.
        NSMutableDictionary *example = [[NSMutableDictionary alloc] init];
        [example setObject:ticker forKey:@"Symbol"];
        
        NSArray *stock = [NSArray arrayWithObjects: ticker, nil];
        NSDictionary *realtimeData = [Controller fetchQuotesFor:stock];
        //TODO load from AppDelegate
        bool isUp = FALSE;
        double lastPrice, openPrice;
        
        @try {
            lastPrice = [[realtimeData valueForKeyPath:@"query.results.quote.LastTradePriceOnly" ]doubleValue];
          openPrice = [[realtimeData valueForKeyPath:@"query.results.quote.Open" ]doubleValue];
        }
        @catch (NSException *exception) {
            NSLog(@"Splash error fetching YQL quotes.");
            lastPrice = -1.0;
            openPrice = -1.0;
        }
        double changeInPercent = (lastPrice / openPrice - 1.0) * 100.0;
        
        if (changeInPercent >= 0) isUp = TRUE;
        [example setObject:[NSNumber numberWithBool:isUp] forKey:@"Positive"];
        [example setObject:[NSNumber numberWithDouble:changeInPercent] forKey:@"PercentChange"];
        [example setObject:[NSNumber numberWithDouble:lastPrice] forKey:@"CurrentPrice"];
        [tickerItems addObject:example];
    }
    [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setTickerItems:tickerItems];*/
}

//move progress indicator
-(void)setProgressStatus:(NSNumber*)percentDone
{
    [progressIndicator setProgress:[percentDone floatValue] animated:YES];
}

@end