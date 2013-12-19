//
//  BT_PieChartView.h
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@class BT_PieChartView;
@interface PieView : UIView

@property double totalPortfolioValue;
@property (nonatomic, retain) NSArray *stocks;
@property (nonatomic, retain) NSMutableDictionary *currentPrices;
@property (nonatomic, retain) BT_PieChartView *parent;

@end

@interface BT_PieChartView : UIView

@property double totalPortfolioValue;
@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, retain) NSArray *stocks;
@property (nonatomic, retain) NSMutableDictionary *stockColors;
@property (nonatomic, retain) NSMutableDictionary *currentPrices;
@property (nonatomic, retain) UIScrollView *legendScrollView;
@property (nonatomic, retain) PieView *pieView;

-(void)calculateCurrentPrices;
-(void)initPieView;

@end