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
#import "StackMob.h"
#import "CorePortfolioHistory.h"

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
    self.rankLabel.text=[NSString stringWithFormat:@"%@", self.userCache.coreModel.portfolio.ranking ];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"received memory warning!");
    [super didReceiveMemoryWarning];
}

/*Check if page has been updated in the last 1 minute.*/
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"last updated: %@", lastUpdated);
    if (!lastUpdated) {
        NSLog(@"initializing lastupdated.");
        lastUpdated = [NSDate date];
        return;
    }
    NSTimeInterval timeSinceUpdate = [lastUpdated timeIntervalSinceNow];
    NSLog(@"time since update: %f", timeSinceUpdate);
    if (timeSinceUpdate < -60) { //60 seconds
        NSLog(@"updating. time since update: %f", timeSinceUpdate);
        [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] downloadCurrentStocksInfo];
        [self viewDidLoad];
    }
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    [self loadWelcomeLabel];
    //[self loadChangeInRank];
}

-(void) loadWelcomeLabel
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
    if (userName != nil) {
        
        [welcomeLabel setText: [NSString stringWithFormat: @"Welcome, %@!", userName]];
    }
}

//-(void) loadChangeInValue
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CorePortfolioHistory"];
//    // query for coremodel for THIS user
//    NSString* getRightHist = [NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userCache.userID];
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightHist]];
//    
//    /**********START CODE BLOCK FOR REQUEST ACTION************/
//    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
//        CorePortfolioHistory *yesterdayHist = [results objectAtIndex:0];
//        NSLog(@"results: %@", yesterdayHist);
//    } onFailure:^(NSError *error) {
//        NSLog(@"There was an error! %@", error);
//    }];
//}

@end