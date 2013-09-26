//
//  BT_RankingsViewController.m
//  BayTrade
//
//  Created by John Luttig on 9/11/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_RankingsViewController.h"
#import "StackMob.h"
#import "CorePortfolioHistory.h"

@interface BT_RankingsViewController ()

@end

@implementation BT_RankingsViewController

@synthesize rankingsTable, loadedRankings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"initializing");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    [self loadRankings];
    NSLog(@"view did load");
}

-(void) loadRankings
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CorePortfolioHistory"];
    // query for coremodel for THIS user
    NSString* getRightHist = [NSString stringWithFormat:@"ranking < %i", 20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightHist]];
    loadedRankings = [[NSMutableArray alloc] init];
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        //CorePortfolioHistory *yesterdayHist = [results objectAtIndex:0];
        for (CorePortfolioHistory *rank in results) {
            [loadedRankings addObject:rank];
        }
        NSLog(@"results: %@", loadedRankings);
        [rankingsTable reloadData];
    } onFailure:^(NSError *error) {
        NSLog(@"There was an error! %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Methods

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [loadedRankings count]; //TODO change
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
    cell.textLabel.text = [[loadedRankings objectAtIndex:indexPath.row] sm_owner];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[[[loadedRankings objectAtIndex:indexPath.row] ranking] intValue]];
    NSLog(@"cell text: %@", cell.textLabel.text);
    //cell.textLabel.text = [self timeString:event.time withAction:action];
    //cell.detailTextLabel.text = actionDetail;
    
    return cell;
}

@end