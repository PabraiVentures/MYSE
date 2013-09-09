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
@synthesize userModel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Take the TabBarControllers model
    self.userModel=((BT_TabBarController*)(self.tabBarController)).userModel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

@end