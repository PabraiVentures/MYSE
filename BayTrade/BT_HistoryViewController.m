//
//  BT_ThirdViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_HistoryViewController.h"
#import "CoreTradeEvent.h"
#import "StockOrder.h"
#import "BT_AppDelegate.h"

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
    self.userCache=[((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) userCache];
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
  
  [self historyUpdate:self.historySelector];
    NSLog(@"view did appear, trying to load stocks.");
  
}

#pragma mark - Table View Methods

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (self.historySelector.selectedSegmentIndex==0) return [events count];
   else return [orders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.historySelector.selectedSegmentIndex ==0 ){
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
    
    NSString *action = @"";
    if (event.actionid.intValue == 0) {
        action = @"Market bought";
    }
    else if (event.actionid.intValue == 1) {
        action = @"Limit bought";
    }
    else if (event.actionid.intValue == 2) {
        action = @"Stop bought";
    }
    else if (event.actionid.intValue == 3) {
        action = @"Market sold";
    }
    else if (event.actionid.intValue == 4) {
        action = @"Limit sold";
    }
    else if (event.actionid.intValue == 5) {
        action = @"Stop sold";
    }
    else NSLog(@"error in event actionID -- no corresponding action for id #%i", event.actionid.intValue);
    NSString *actionDetail = [NSString stringWithFormat:@"\n%@ %@ shares of %@\nTrade Value: $%.2f x %@ = $%.2f", action, event.tradeamount, [event.ticker uppercaseString], [event.tradeprice doubleValue], event.tradeamount, doMath];
    
    cell.textLabel.text = [self timeString:event.time withAction:action];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
    
  }
  
  
  else{ // if we need to update with stock orders
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.numberOfLines = 5;
    
    StockOrder *order = [orders objectAtIndex:indexPath.row];
    
    double doMath = order.quantity.intValue * order.price.doubleValue;
    
    NSString *action = @"";
    if (order.tradetype.intValue == 0) {
      action = @"Market buy";
    }
    else if (order.tradetype.intValue == 1) {
      action = @"Limit buy";
    }
    else if (order.tradetype.intValue == 2) {
      action = @"Stop buy";
    }
    else if (order.tradetype.intValue == 3) {
      action = @"Market sell";
    }
    else if (order.tradetype.intValue == 4) {
      action = @"Limit sell";
    }
    else if (order.tradetype.intValue == 5) {
      action = @"Stop sell";
    }
    else NSLog(@"error in order tradetype -- no corresponding action for tradetype #%i", order.tradetype.intValue);
    NSString *actionDetail = [NSString stringWithFormat:@"\n%@ %@ shares of %@\nEstimated Trade Value: $%.2f x %@ = $%.2f", action, order.quantity, [order.symbol uppercaseString], [order.price doubleValue], order.quantity, doMath];
    
    cell.textLabel.text = [self timeString:order.ordertime withAction:action];
    cell.detailTextLabel.text = actionDetail;
    
    return cell;
    
  }
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
  if (tradeDate ==NULL) return @"NOTIME";
    NSString *time;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *date = [dateFormatter dateFromString:tradeDate];
    int seconds = -(int)[date timeIntervalSinceNow];
    int hours = seconds/3600;
    int minutes = seconds/60;
  
  NSLog(@"date\n\n = %@ hours= %d minutes= %d seconds =%d", date, hours,minutes,seconds);

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

- (IBAction)historyUpdate:(UISegmentedControl *)sender {
  
  if (sender.selectedSegmentIndex == 0){
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
    else{
      events=NULL;
      [historyTable reloadData];
    }
  } onFailure:^(NSError *error) {
    NSLog(@"Error fetching: %@", error);
  }];
    
  }
  
  else {
    //need to load the  pending stock orders
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"StockOrder"];
    // query for stockorder for THIS user
    NSString* getRightEvents=[NSString stringWithFormat:@"sm_owner == 'user/%@'",self.userCache.userID ];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightEvents]];
    
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *tradeOrders) {
      
      if([tradeOrders count] > 0)
      {
        /** Sort the tradeEvents by time/supposed order of events **/
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ordertime" ascending:NO] ;
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        orders = [tradeOrders sortedArrayUsingDescriptors:sortDescriptors];
        [historyTable reloadData];
      }
      else{
        orders=NULL;
        [historyTable reloadData];
      }
    } onFailure:^(NSError *error) {
      NSLog(@"Error fetching: %@", error);
    }];
    
    
  }
  
  
}
@end