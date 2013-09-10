//
//  BT_PortfolioViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/5/13.
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

@interface BT_PortfolioViewController ()

@end

@implementation BT_PortfolioViewController

@synthesize stockTable;

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
    self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.stocks = [self.userCache.coreModel.portfolio.stocks allObjects];
    [stockTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Methods

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

@end