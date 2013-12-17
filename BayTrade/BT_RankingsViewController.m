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
#import <FacebookSDK/FacebookSDK.h>

@interface BT_RankingsViewController ()

@end

@implementation BT_RankingsViewController

@synthesize rankingsTable, loadedRankings,rankingSegment;

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
    if (rankingSegment.selectedSegmentIndex == 1) {
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
        return;
    }
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error || !result) return;
         NSMutableArray* predicateArray=[[NSMutableArray alloc] init];
         NSArray*  fetchedFriendData = [[NSArray alloc] initWithArray:[result objectForKey:@"data"]];
         NSLog(@"--%@---",fetchedFriendData);
         for (int i = 0; i < fetchedFriendData.count-1; i++){
             // for each friend
             [predicateArray addObject: [NSString stringWithFormat: @"user/%@",[( (NSDictionary*) [fetchedFriendData objectAtIndex:i] ) objectForKey:@"id"]]]; //build predicate array
         }
         NSArray* hardArray = [NSArray arrayWithArray:predicateArray];
         NSPredicate* cpredicate = [NSPredicate predicateWithFormat:@"sm_owner IN %@",hardArray];
         NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CorePortfolioHistory"];
         // query for coremodel for THIS user
         [fetchRequest setPredicate:cpredicate];
         loadedRankings = [[NSMutableArray alloc] init];
         /**********START CODE BLOCK FOR REQUEST ACTION************/
         [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
             //CorePortfolioHistory *yesterdayHist = [results objectAtIndex:0];
             for (CorePortfolioHistory *rank in results) {
                 [loadedRankings addObject:rank];
             }
             NSLog(@"results: %@", results);
             [rankingsTable reloadData];
         } onFailure:^(NSError *error) {
             NSLog(@"There was an error! %@", error);
         }];
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
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) setCellPic: (NSDictionary*) pair
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small", [pair objectForKey: @"userID"]]];
    NSLog(@"url: %@", url);
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    NSLog(@"img: %@", img);
    NSLog(@"set image for pic: %@", pair);
    if (img != nil) {
        UIImage *newImage = [self imageWithImage:img scaledToSize: CGSizeMake(100, 100)];
        [[[rankingsTable cellForRowAtIndexPath: [pair objectForKey:@"index"]] imageView] performSelectorOnMainThread:@selector(setImage:) withObject:newImage waitUntilDone:NO];
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *userID = [[loadedRankings objectAtIndex:indexPath.row] sm_owner];
    cell.textLabel.text = userID;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[[[loadedRankings objectAtIndex:indexPath.row] ranking] intValue]];
    NSDictionary *pair = [[NSMutableDictionary alloc] init];
    userID = [userID substringFromIndex:5];
    [pair setValue:userID forKey:@"userID"];
    [pair setValue:indexPath forKey:@"index"];
    UIImage *img = [self imageWithImage:[UIImage imageNamed:@"silhouette.jpg"] scaledToSize:CGSizeMake(100, 100)];
    [cell.imageView setImage:img];
    [self performSelectorInBackground:@selector(setCellPic:) withObject: pair];
    NSLog(@"cell text: %@", cell.textLabel.text);
    return cell;
}

- (IBAction)rankSegmentChanged:(id)sender {
    [self loadRankings];
}
@end