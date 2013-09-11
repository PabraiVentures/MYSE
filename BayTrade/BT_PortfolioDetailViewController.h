//
//  BT_PortfolioDetailViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BT_PortfolioDetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webChart;

-(IBAction)back:(id)sender;

@end