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
#import "Coremodel.h"
#import "Corestock.h"
#import "Coreportfolio.h"
#import "Coretradeevent.h"
#import "StackMob.h"

@interface BT_HistoryViewController : UIViewController <UITabBarControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (weak, nonatomic) Model* userModel;
@property(weak,nonatomic) NSManagedObjectContext *managedObjectContext;
@end