//
//  BT_RankingsViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/11/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"
#import <iAd/iAd.h>
@interface BT_RankingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *rankingsTable;
@property (nonatomic, retain) NSMutableArray *loadedRankings;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak,nonatomic) Cache* userCache;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rankingSegment;
@property (weak, nonatomic) IBOutlet ADBannerView *ad;
- (IBAction)rankSegmentChanged:(id)sender;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end