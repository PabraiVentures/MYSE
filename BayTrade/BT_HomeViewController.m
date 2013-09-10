//
//  BT_FirstViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//
#import "BT_TabBarController.h"
#import "BT_HomeViewController.h"
#import "BT_TabBarController.h"
#import "Cache.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreStock.h"

@interface BT_HomeViewController ()

@end

@implementation BT_HomeViewController
@synthesize userCache, welcomeLabel, tickerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Take the TabBarController's model
    self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
    
    [self.tickerView loadTickerData];
    [self.tickerView reloadData];
}

- (void)didReceiveMemoryWarning
{
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