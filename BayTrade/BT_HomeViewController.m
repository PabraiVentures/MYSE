//
//  BT_FirstViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//
#import "BT_HomeViewController.h"
#import "Cache.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreStock.h"
#import "BT_AppDelegate.h"

@interface BT_HomeViewController ()

@end

@implementation BT_HomeViewController
@synthesize userCache, welcomeLabel, tickerView, pieChart;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Take the TabBarController's model
    self.userCache=[((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) userCache];
    
    [self.pieChart setUserCache:self.userCache];
    [self.pieChart setStocks:[self.userCache.coreModel.portfolio.stocks allObjects]];
    [self.pieChart calculateCurrentPrices];
    [self.pieChart setNeedsDisplay];
    
    [self.tickerView loadTickerData];
    [self.tickerView reloadData];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"received memory warning!");
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadWelcomeLabel];
}

-(void) loadWelcomeLabel
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
    if (userName != nil) {
        
        [welcomeLabel setText: [NSString stringWithFormat: @"Welcome, %@!", userName]];
    }
}

@end