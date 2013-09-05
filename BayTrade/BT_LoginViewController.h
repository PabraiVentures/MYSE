//
//  BT_loginViewController.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 8/13/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface BT_LoginViewController : UIViewController
- (IBAction)loginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextView *statusText;

@end