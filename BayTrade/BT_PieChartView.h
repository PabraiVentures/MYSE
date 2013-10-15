//
//  BT_PieChartView.h
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_PieChartView : UIView {
    double totalPortfolioValue;
}

@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, retain) NSArray *stocks;
@property (nonatomic, retain) NSMutableDictionary *stockColors;
@property (nonatomic, retain) NSMutableArray *currentPrices;
@property (nonatomic, retain) UIView *legendView;

-(void)calculateCurrentPrices;

@end