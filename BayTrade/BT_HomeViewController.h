//
//  BT_FirstViewController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_HomeViewController : UIViewController
@property (nonatomic,strong) Cache* userCache;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end