//
//  BT_TabBarController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_TabBarController.h"
#import "StackMob.h"

@interface BT_TabBarController ()

@end

@implementation BT_TabBarController
@synthesize userModel;
@synthesize managedObjectContext;

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
    self.userModel = [[Cache alloc] init];
    NSUserDefaults  *defaults=[NSUserDefaults standardUserDefaults];
    self.userModel.userID = [defaults objectForKey:@"userID"];
}

@end