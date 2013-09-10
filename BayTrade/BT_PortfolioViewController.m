//
//  BT_PortViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/9/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_PortfolioViewController.h"
#import "BT_TabBarController.h"
#import <CoreData/CoreData.h>
#import "CoreModel.h"
#import "CoreStock.h"
#import "CorePortfolio.h"
#import "Cache.h"
#import "Controller.h"
#import "BT_AppDelegate.h"

@interface BT_PortfolioViewController ()

@end

@implementation BT_PortfolioViewController

@synthesize currentPrices;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] setPortfolioView:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
    [self calculateCurrentPrices];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget: self action: @selector(refreshControlRequest) forControlEvents: UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self setRefreshControl:refreshControl];
}

-(void)refreshControlRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // (...code to get new data here...)
        [self calculateCurrentPrices];
        dispatch_async(dispatch_get_main_queue(), ^{
            //any UI refresh
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            [fmt setDateFormat:@"MMM d, h:mm:ss a"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [fmt stringFromDate:[NSDate date]]];
            [[self refreshControl] setAttributedTitle: [[NSAttributedString alloc] initWithString:lastUpdated]];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

-(void) viewWillAppear:(BOOL)animated
{
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
    [self calculateCurrentPrices];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // eventually 2+ for shorted stocks, etc.
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userCache.coreModel.portfolio.stocks count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.numberOfLines = 5;
    
    CoreStock *stock = [self.stocks objectAtIndex: indexPath.row];
    double value = [[currentPrices objectAtIndex:indexPath.row] doubleValue] * [stock.amount doubleValue];
    
    NSString *actionDetail = [NSString stringWithFormat:@"Purchase Share Price: $%.2f\nCurrent Share Price: $%.2f\nCurrent Value: $%.2f", [stock.buyprice doubleValue], [[Controller currentPriceForSymbol:stock.symbol] doubleValue], value];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i shares of %@", [stock.amount intValue], [stock.symbol uppercaseString]];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
}

-(void)calculateCurrentPrices
{
    currentPrices = [[NSMutableArray alloc] init];
    for (CoreStock *stock in self.stocks) {
        [currentPrices addObject:[Controller currentPriceForSymbol:stock.symbol]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] setSelectedPortfolioStock:[self.stocks objectAtIndex: indexPath.row]];
    //TODO go to detail view
}

@end