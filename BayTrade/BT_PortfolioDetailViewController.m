//
//  BT_PortfolioDetailViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_PortfolioDetailViewController.h"
#import "CoreStock.h"
#import "BT_AppDelegate.h"
#import "Controller.h"

@interface BT_PortfolioDetailViewController ()

@end

@implementation BT_PortfolioDetailViewController

@synthesize detailLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"begin init");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    NSLog(@"end init");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self performSelector:@selector(setDetailLabelText) withObject:nil afterDelay:0.5];
}

-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self removeFromParentViewController];
}

-(void)setDetailLabelText
{
    CoreStock *detailStock = [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] selectedPortfolioStock];
    NSLog(@"detailstock: %@", detailStock);
    NSDictionary *data;
    @try {
        data = [Controller fetchQuotesFor:[NSArray arrayWithObject: detailStock.symbol]];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!"
                                                        message:@"Can't get data!"
                                                       delegate:self cancelButtonTitle:@"Okay."
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSLog(@"data: %@", data);
    NSString *myStockPrice = data[@"LastTradePriceOnly"];
    NSString *openPrice = data[@"Open"];
    
    double lastPrice = [myStockPrice doubleValue];
    double open  = [openPrice    doubleValue];
    
    NSString *detailString = [NSString stringWithFormat:@"Symbol: %@\n\nLast Trade Price: %.2f\n\nOpen Price: %.2f", detailStock.symbol, lastPrice, open];
    
    [detailLabel setText:detailString];
}

@end