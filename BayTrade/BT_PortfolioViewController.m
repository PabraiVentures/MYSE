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
    for(CoreStock* stock in self.userModel.coreModel.portfolio.stocks)
    {
        
    }
}

@end