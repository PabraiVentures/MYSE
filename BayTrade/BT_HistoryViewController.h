//
//  BT_ThirdViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "BT_TabBarController.h"
#import "BT_HistoryViewController.h"
#import "BT_TradeEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreModel.h"
#import "CoreStock.h"
#import "CorePortfolio.h"
#import "CoreTradeEvent.h"
#import "StackMob.h"

@interface BT_HistoryViewController : UIViewController <UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSArray *events;
}

@property (strong, nonatomic) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) Model* userModel;
@property (weak,nonatomic) NSManagedObjectContext *managedObjectContext;

@end