//
//  BT_SplashViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_SplashViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIProgressView *progressIndicator;
@property (nonatomic, strong) Cache *userCache;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)downloadCurrentStocksInfo;

@end