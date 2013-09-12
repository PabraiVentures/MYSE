//
//  BT_RankingsViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/11/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BT_RankingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *rankingsTable;

@end