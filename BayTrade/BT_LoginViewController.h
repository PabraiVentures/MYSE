//
//  BT_loginViewController.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 8/13/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface BT_LoginViewController : UIViewController <UIAlertViewDelegate> {
    NSString *token;
}

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextView *statusText;

- (IBAction)loginButtonPressed:(id)sender;
- (void)updateView;

@end