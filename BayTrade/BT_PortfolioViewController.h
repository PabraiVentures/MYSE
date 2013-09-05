//
//  BT_PortfolioViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/5/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface BT_PortfolioViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) Model* userModel;
@property (nonatomic, retain) IBOutlet UITableView *stockTable;

@end