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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget: self action: @selector(refreshControlRequest) forControlEvents: UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self setRefreshControl:refreshControl];
}

-(void)refreshControlRequest
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [fmt stringFromDate:[NSDate date]]];
    [[self refreshControl] setAttributedTitle: [[NSAttributedString alloc] initWithString:lastUpdated]];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
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
    double value = [[Controller currentPriceForSymbol:stock.symbol] doubleValue] * [stock.amount doubleValue];
    
    NSString *actionDetail = [NSString stringWithFormat:@"Purchase Share Price: $%.2f\nCurrent Share Price: $%.2f\nCurrent Value: $%.2f", [stock.buyprice doubleValue], [[Controller currentPriceForSymbol:stock.symbol] doubleValue], value];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i shares of %@", [stock.amount intValue], [stock.symbol uppercaseString]];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate

//-(void)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"begin will select");
//    //[(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] setSelectedPortfolioStock:[self.stocks objectAtIndex: indexPath.row]];
//    NSLog(@"end will select");
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] setSelectedPortfolioStock:[self.stocks objectAtIndex: indexPath.row]];
    //TODO go to detail view
}

@end