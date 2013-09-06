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
#import "Model.h"

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
    self.userModel=((BT_TabBarController*)(self.tabBarController)).userModel;
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
    return [self.userModel.coreModel.portfolio.stocks count];
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
    
    CoreStock *stock = [self.userModel.coreModel.portfolio.stocks objectAtIndex:indexPath.row];
    
    double value = [stock.currentprice doubleValue] * [stock.amount doubleValue];
    
    NSString *actionDetail = [NSString stringWithFormat:@"Purchase Share Price: %.2f\nCurrent Share Price: %.2f\nCurrent Value: %.2f", [stock.buyprice doubleValue], [stock.currentprice doubleValue], value];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i shares of %@", [stock.amount intValue], [stock.symbol uppercaseString]];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
}

@end