//
//  BT_ThirdViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_HistoryViewController.h"
#import "CoreTradeEvent.h"
@interface BT_HistoryViewController ()

@end

@implementation BT_HistoryViewController

@synthesize historyTable;

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
    self.userCache=((BT_TabBarController*)(self.tabBarController)).userModel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillDisappear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{    
    //get the trade events for this user
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreTradeEvent"];
    // query for tradeevents for THIS user
    NSString* getRightEvents=[NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userCache.userID ];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightEvents]];
    
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *tradeEvents) {
        
        if([tradeEvents count] > 0)
        {
            /** Sort the tradeEvents by time/supposed order of events **/
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            events = [tradeEvents sortedArrayUsingDescriptors:sortDescriptors];
            [historyTable reloadData];
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
}

#pragma mark - Table View Methods

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [events count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.numberOfLines = 5;
    
    CoreTradeEvent *event = [events objectAtIndex:indexPath.row];
    
    double doMath = event.tradeamount.intValue * event.tradeprice.doubleValue;
    
    NSString *action = @"Sold";
    if (event.actionid.intValue == 1)
    {
        action = @"Bought";
    }

    NSString *actionDetail = [NSString stringWithFormat:@"\n%@ %@ shares of %@\nTrade Value: $%.2f x %@ = $%.2f", action, event.tradeamount, [event.ticker uppercaseString], [event.tradeprice doubleValue], event.tradeamount, doMath];
    
    cell.textLabel.text = [self timeString:event.time withAction:action];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[(CoreTradeEvent*)[events objectAtIndex:indexPath.row] actionid] intValue] == 1) { //if this was a selling trade event
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.2];
        return;
    }
    cell.backgroundColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.2];
}

-(NSString*) timeString: (NSString*) tradeDate withAction: (NSString*) action
{
    NSString *time;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    NSDate *date = [dateFormatter dateFromString:tradeDate];
    
    int seconds = -(int)[date timeIntervalSinceNow];
    int hours = seconds/3600;
    int minutes = seconds/60;
    if (hours < 24) {
        time = [NSString stringWithFormat:@"%@ %i hours ago", action, hours];
        if (minutes < 60) time = [NSString stringWithFormat:@"%@ %i minutes ago", action, minutes];
        if (minutes < 1) time = [NSString stringWithFormat:@"%@ just now", action];
    }
    else {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
        
        int hour = [components hour];
        int minute = [components minute];
        int day = [components day];
        int month = [components month];
        int year = [components year];
        time = [NSString stringWithFormat:@"%@ at %i:%i on %i/%i/%i", action, hour, minute, month, day, year];
    }
    return time;
}

@end