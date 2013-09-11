//
//  BT_PortfolioTileViewController.h
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cache.h"

@interface BT_PortfolioTileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) Cache* userCache;
@property (nonatomic, retain) NSArray *stocks;
@property (nonatomic, retain) NSMutableArray *currentPrices;
@property (nonatomic, retain) IBOutlet UICollectionView *tileView;
@property (nonatomic, retain) IBOutlet UITextView *detailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *chartImage;

@end