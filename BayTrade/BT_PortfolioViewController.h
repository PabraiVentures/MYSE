//
//  BT_PortfolioViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/5/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_PortfolioViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, retain) NSArray *stocks;
//@property (nonatomic, retain) UIRefreshControl *refreshControl;

-(void)refreshControlRequest;

@end