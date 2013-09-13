//
//  BT_SplashViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/12/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_SplashViewController : UIViewController {
    //int totalItems;
}

@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicator;
@property (nonatomic, retain) Cache *userCache;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)downloadCurrentStocksInfo;

@end