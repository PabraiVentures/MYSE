//
//  BT_FirstViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import "BT_TickerView.h"
#import "BT_PieChartView.h"

@interface BT_HomeViewController : UIViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, strong) IBOutlet BT_TickerView *tickerView;
@property (strong, nonatomic) IBOutlet BT_PieChartView *pieChart;

@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *changeInRankingImage;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;

@end