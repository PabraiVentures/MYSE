//
//  BT_ThirdViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_HistoryViewController.h"
@interface BT_HistoryViewController ()

@end

@implementation BT_HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //get the object context to work with stackmob data
    
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    self.userModel=((BT_TabBarController*)(self.tabBarController)).userModel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) BS {
    //when you die nothing happens
}

-(void) viewWillDisappear:(BOOL)animated{
    [self.ScrollView removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 65.0, 320.0, 465.0) ];
    [self.view addSubview:self.ScrollView];
    
    //get the trade events for this user
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Coretradeevent"];
    // query for tradeevents for THIS user
    NSString* getRightEvents=[ NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userModel.userID ];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightEvents]];
    
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *tradeEvents) {
        
        if([tradeEvents count] > 0)
        {
            /** Sort the tradeEvents by time/supposed order of events **/
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            tradeEvents = [tradeEvents sortedArrayUsingDescriptors:sortDescriptors];
            
            
            //Use Sorted array to visualize data
            int count = 0;
            for (Coretradeevent *event in tradeEvents) {
                NSLog(@"At %@ you %@ %@ amount: %@ price: %@", event.time, (event.actionid.intValue > 0)? @"bought" : @"sold" ,event.ticker, event.tradeamount, event.tradeprice);
                
                
                UIButton* button = [self makeAButton:event];
                button.frame = CGRectMake(10.0, count, 300.0, 85.0);
       
                //SET SCROLLVIEW SIZE
                CGSize contentSize=self.ScrollView.frame.size;
                int numEvents = [tradeEvents count];
                if (numEvents > 5)
                {
                    contentSize.height = numEvents * 90;
                }
                else
                {
                    contentSize.height= self.view.frame.size.height;
                }
                [self.ScrollView setContentSize:contentSize];
                
                //Draw button on scrollview
                [self.ScrollView addSubview:button];
                count+=90;
            }
            
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

/**
 Makes a button (for display only) for a Coretradeevent
 */
-(UIButton*) makeAButton :(Coretradeevent*) event
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.layer.borderWidth = 0.5f;
    button.layer.cornerRadius = 10.0f;
    NSString* action = @"Sold";
    
    if(event.actionid.intValue > 0)//if actionID = 1 -> buy
    {
        action = @"Bought";
        UIColor* c = [UIColor colorWithHue:.6 saturation:.75 brightness:.55 alpha:.53];
        button.backgroundColor = c;
    }
    else{
        UIColor* c = [UIColor colorWithHue:1 saturation:.75 brightness:.5 alpha:.53
                      ];
        button.backgroundColor = c;
    }
    double doMath = event.tradeamount.intValue * event.tradeprice.doubleValue;
    
    NSString *butttitle=[NSString stringWithFormat:@"%@\n%@ %@ shares of %@\nTrade Value: $%@ x %@ = %.2f", event.time, action, event.tradeamount, event.ticker, event.tradeprice, event.tradeamount, doMath];
    
    [button addTarget:self
               action:@selector(BS)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:butttitle forState:UIControlStateNormal];
    
    button.enabled=false;
    
    return button;
}

@end