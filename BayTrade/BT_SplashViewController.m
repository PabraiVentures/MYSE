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
    [self performSelector:@selector(loadTickerData) withObject:nil afterDelay:2.5];
  [self performSelector:@selector(setCoreModel) withObject:nil afterDelay: 2.5l];
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

            [self performSelector:@selector(setProgressStatus:) withObject:progPercent ];
    }
    @catch(NSException* e){
        NSLog(@"Error spashsscreen loading data\n%@", e);
    
        }

  [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setCurrentStockPrices:currentPrices];
  [self performSelector:@selector(done) withObject:nil afterDelay:3.4];

}

- (void) done
{
    NSLog(@"load success; going to trade view");
    [self performSegueWithIdentifier:@"loadSuccess" sender:nil ];
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
            [self performSelector:@selector(downloadCurrentStocksInfo) withObject:nil];
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
   NSMutableArray *tickerItems = [[NSMutableArray alloc] init];
    
    NSArray *tickers = [NSArray arrayWithObjects:@"AAPL", @"GOOG", @"MSFT", @"BA", @"F", nil];

 NSArray *results= [[Controller fetchQuotesFor:tickers]valueForKeyPath:@"query.results.quote"];// this is an array of quotes
  int index=0;
  for (NSDictionary *stock in results ){
    //for each stocks quote
    
    
    
    NSString* ticker= [results valueForKey:@"symbol"];
    
    
    NSMutableDictionary *example = [[NSMutableDictionary alloc] init];
    // example has the ticker data for each stock , there are multiple of these
    [example setObject:ticker forKey:@"Symbol"];
    
    NSArray *stock = [NSArray arrayWithObjects: ticker, nil];
    //TODO load from AppDelegate
    bool isUp = FALSE;
    double lastPrice, openPrice;
    
    @try {
      lastPrice = [[[results objectAtIndex: index ] valueForKey:@"LastTradePriceOnly" ]doubleValue];
      openPrice = [[[results objectAtIndex:index ] valueForKey:@"Open" ]doubleValue];
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

    index++;
  }
  //example is a dictionary. it has Symbol, Positive, PercentChange, CurrentPrice
//    for (NSString *ticker in tickers) { //needs to be for each stock returned from fetchquotes set  all of the example dictionary's values.
  [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) setTickerItems:tickerItems];
}

//move progress indicator
-(void)setProgressStatus:(NSNumber*)percentDone
{
    [progressIndicator setProgress:[percentDone floatValue] animated:YES];
}

@end