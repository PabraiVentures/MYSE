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
@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, strong) IBOutlet BT_TickerView *tickerView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet BT_PieChartView *pieChart;

@end