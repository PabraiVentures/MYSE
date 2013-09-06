//
//  BT_FirstViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//
#import "BT_TabBarController.h"
#import "BT_HomeViewController.h"
#import "BT_TabBarController.h"
#import "Model.h"
#import "BT_TradeEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "Stock.h"

@interface BT_HomeViewController ()

@end

@implementation BT_HomeViewController
@synthesize userModel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Take the TabBarControllers model
    self.userModel=((BT_TabBarController*)(self.tabBarController)).userModel;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self addTopButtons];
    [self addLargestHoldings];

}

-(void) Bs
{
 }

-(void) addLargestHoldings
{
    
    //sort by largest stock value
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalValue" ascending:NO] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.userModel.modelPort.stocks sortedArrayUsingDescriptors:sortDescriptors];
    
    //need to take care of removing stocks and having less stocks then last time on page!!!!!!!
    
    //replace current array with sorted array
    self.userModel.modelPort.stocks = [NSMutableArray arrayWithArray:sortedArray];
    
    if([self.userModel.modelPort.stocks count] > 0)
    {
        int counter = 0;
        int position = 80;
        while (counter < 4 && counter < [self.userModel.modelPort.stocks count]) {
            [self buildLargestStockButtons: counter++ andPos:position];
            position += 50;
        }
    }
    
}

-(void) buildLargestStockButtons: (int) index andPos: (int) pos
{
    UIButton *buttonL = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonL.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buttonL.titleLabel.textAlignment = NSTextAlignmentLeft;
    buttonL.layer.borderWidth = 0.5f;
    buttonL.layer.cornerRadius = 10.0f;
    UIColor* c = [UIColor colorWithHue:.53 saturation:.85 brightness:.75 alpha:1];
    
    buttonL.backgroundColor = c;

    
    NSString *leftTitle=[NSString stringWithFormat:@"%@            $%.2f", ((Stock*)([self.userModel.modelPort.stocks objectAtIndex:index])).symbol,
                         ((Stock*)([self.userModel.modelPort.stocks objectAtIndex:index])).totalValue ];
    
    
    buttonL.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonL addTarget:self
                action:@selector(BS)
      forControlEvents:UIControlEventTouchDown];
    [buttonL setTitle:leftTitle forState:UIControlStateNormal];
    buttonL.frame = CGRectMake(10.0, pos, 300.0, 45.0);
    buttonL.enabled=false;
    [self.scrollView addSubview:buttonL];
}


//Adds top buttons to home page
-(void) addTopButtons
{
    UIButton *buttonL = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *buttonR = [UIButton buttonWithType:UIButtonTypeCustom];
    
    buttonL.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buttonL.titleLabel.textAlignment = NSTextAlignmentCenter;
    buttonL.layer.borderWidth = 0.5f;
    buttonL.layer.cornerRadius = 10.0f;
    
    buttonR.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    buttonR.titleLabel.textAlignment = NSTextAlignmentCenter;
    buttonR.layer.borderWidth = 0.5f;
    buttonR.layer.cornerRadius = 10.0f;
    
    UIColor* c = [UIColor colorWithHue:.53 saturation:.85 brightness:.75 alpha:1];
    
    buttonL.backgroundColor = c;
    buttonR.backgroundColor = c;
    
    NSString *leftTitle=[NSString stringWithFormat:@"Account Value(USD):\n$%.2f", self.userModel.modelPort.totalportfoliovalue.floatValue];
    
    buttonL.titleLabel.font = [UIFont systemFontOfSize:14];
    buttonR.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [buttonL addTarget:self
                action:@selector(BS)
      forControlEvents:UIControlEventTouchDown];
    [buttonL setTitle:leftTitle forState:UIControlStateNormal];
    buttonL.frame = CGRectMake(10.0, 45.0, 140.0, 45.0);
    buttonL.enabled=false;
    
    
    
    [buttonR addTarget:self
                action:@selector(BS)
      forControlEvents:UIControlEventTouchDown];
    [buttonR setTitle:leftTitle forState:UIControlStateNormal];
    buttonR.frame = CGRectMake(165.0, 45.0, 140.0, 45.0);
    buttonR.enabled=false;
    
    [self.scrollView addSubview:buttonL];
    [self.scrollView addSubview:buttonR];
}

@end