//
//  BT_PortfolioTileViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_PortfolioTileViewController.h"
#import "Controller.h"
#import "CoreStock.h"
#import "BT_AppDelegate.h"

#define kTagSymbolLabel 50
#define kTagPercentLabel 60

@interface BT_PortfolioTileViewController ()

@end

@implementation BT_PortfolioTileViewController

@synthesize tileView, userCache, stocks, currentPrices, detailLabel, chartImage;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view did appear");
    [self calculateCurrentPrices];//must be first!
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
    [self calculateCurrentPrices];
    if (self.stocks.count >= 1)
        [self loadDetailForIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)calculateCurrentPrices
{
    self.currentPrices = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) currentStockPrices];

    //remove once splash screen is complete
//    self.currentPrices = [[NSMutableArray alloc] init];
//    for (CoreStock *stock in self.stocks) {
//        [self.currentPrices addObject:[Controller fetchQuotesFor:[NSArray arrayWithObject:stock.symbol]]];
//    }
}

-(UIColor *) colorForIndex: (int)index
{
    double tradePrice;
    double openPrice;
    
    @try {
        tradePrice = [[[self.currentPrices objectAtIndex:index] objectForKey:@"LastTradePriceOnly"] doubleValue];
        openPrice = [[[self.currentPrices objectAtIndex:index] objectForKey:@"Open"] doubleValue];
    }
    @catch (NSException *exception) {
        NSLog(@"error fetching YQL quotes");
        tradePrice = -1.0;
        openPrice = -1.0;
    }
    double pctChange =  tradePrice/openPrice - 1.0;
    
    if (pctChange < 0) {
        if (pctChange < -0.05) {
            return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
        }
        if (pctChange < -0.03) {
            return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.8];
        }
        if (pctChange < -0.01) {
            return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.6];
        }
        return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4];
    }
    if (pctChange > 0) {
        if (pctChange > 0.05) {
            return [UIColor colorWithRed:0 green:1.0 blue:0 alpha:1.0];
        }
        if (pctChange > 0.03) {
            return [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.8];
        }
        if (pctChange > 0.01) {
            return [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.6];
        }
        return [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.4];
    }
    return [UIColor yellowColor];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"Found %i stocks for Portfolio Tiles.", self.stocks.count);
    return self.stocks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.backgroundColor = [self colorForIndex:indexPath.row];
    
    UILabel *symbolLabel = (UILabel*)[cell viewWithTag:kTagSymbolLabel];
    symbolLabel.text = [(CoreStock*)[stocks objectAtIndex:indexPath.row] symbol];
    
    UILabel *percentLabel = (UILabel*)[cell viewWithTag:kTagPercentLabel];
    NSDictionary *data;
    @try {
        data = [self.currentPrices objectAtIndex:indexPath.row];
      NSString *myStockPrice = data[@"LastTradePriceOnly"];
      NSString *openPrice = data[@"Open"];
      double percentChange = ([myStockPrice doubleValue] / [openPrice doubleValue] - 1) *100;
      NSString *percentChangeString;
      if (percentChange >= 0) percentChangeString = [NSString stringWithFormat: @"+%.2f", percentChange];
      else percentChangeString = [NSString stringWithFormat: @"%.2f", percentChange];
      
      percentLabel.text = percentChangeString;

    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:[NSString stringWithFormat:@"Can't get data! Error: %@", exception] delegate:self cancelButtonTitle:@"Okay." otherButtonTitles: nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
       return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    [self loadDetailForIndex:indexPath.row];
}

#pragma mark - Detail View

-(void)loadDetailForIndex: (int) selectedIndex
{
    CoreStock *detailStock = [self.stocks objectAtIndex:selectedIndex];
    NSDictionary *data;
    @try {
        data = [self.currentPrices objectAtIndex:selectedIndex];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:[NSString stringWithFormat:@"Can't get data! Error: %@", exception] delegate:self cancelButtonTitle:@"Okay." otherButtonTitles: nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    NSString *myStockPrice = data[@"LastTradePriceOnly"];
    NSString *openPrice = data[@"Open"];
    
    double lastPrice;
    double open;
    
    @try {
        lastPrice = [myStockPrice doubleValue];
        open = [openPrice doubleValue];
    }
    @catch (NSException *exception) {
        NSLog(@"error fetching prices from YQL");
        lastPrice = -1.0;
        open = -1.0;
    }
    int       amount = [detailStock.amount intValue];
    double  buyPrice = [detailStock.buyprice doubleValue];
    
    NSString *detailString = [NSString stringWithFormat:@"Symbol: %@\n\nAmount Owned: %i\n\nBuy Price: %.2f\nTotal Purchase Value: %.2f\n\nLast Trade Price: %.2f\nTotal Current Value: %.2f\n\nOpen Price: %.2f", detailStock.symbol, amount, buyPrice, buyPrice*amount, lastPrice, lastPrice*amount, open];
    
    [detailLabel setText:detailString];
    [detailLabel setContentOffset:CGPointMake(0, 0) animated:YES];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://chart.finance.yahoo.com/z?s=%@&t=6m&q=l&l=on&z=s&p=m50,m200", detailStock.symbol];
    NSURL *url = [NSURL URLWithString:fullURL];
    
    @try {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
        [chartImage setImage:image];
    }
    @catch (NSException *exception) {
        NSLog(@"couldn't find chart for symbol.");
    }
}

/**code from old portfolio view that may be used for refresh function**/
//UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//[refreshControl addTarget: self action: @selector(refreshControlRequest) forControlEvents: UIControlEventValueChanged];
//refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
//[self setRefreshControl:refreshControl];
//}
//
//-(void)refreshControlRequest
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // (...code to get new data here...)
//        [self calculateCurrentPrices];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //any UI refresh
//            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//            [fmt setDateFormat:@"MMM d, h:mm:ss a"];
//            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [fmt stringFromDate:[NSDate date]]];
//            [[self refreshControl] setAttributedTitle: [[NSAttributedString alloc] initWithString:lastUpdated]];
//            [self.tableView reloadData];
//            [self.refreshControl endRefreshing];
//        });
//    });
//}

@end