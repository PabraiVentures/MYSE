//
//  BT_ThirdViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import "BT_HistoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreModel.h"
#import "CoreStock.h"
#import "CorePortfolio.h"
#import "CoreTradeEvent.h"
#import "StackMob.h"

@interface BT_HistoryViewController : UIViewController <UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSArray *events;
  NSArray *orders;
}
- (IBAction)historyUpdate:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *historySelector;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) Cache* userCache;
@property (weak,nonatomic) NSManagedObjectContext *managedObjectContext;

@end