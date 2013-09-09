//
//  BT_TabBarController.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import "BT_LoginViewController.h"

@interface BT_TabBarController : UITabBarController
@property (nonatomic,strong) Cache *userModel;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) BT_LoginViewController *login;


@end