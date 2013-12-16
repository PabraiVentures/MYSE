//
//  StockOrder.h
//  BayTrade
//
//  Created by Nathan Pabrai on 11/16/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CorePortfolio;

@interface StockOrder : NSManagedObject

@property (nonatomic,retain)NSNumber *price;
@property (nonatomic, retain) NSNumber * addedtolookup;
@property (nonatomic, retain) NSString * ordertime;
@property (nonatomic, retain) NSNumber * islongposition;
@property (nonatomic, retain) NSNumber * lasttimeprocessed;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * sm_owner;
@property (nonatomic, retain) NSString * stockorder_id;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic,retain) NSString * status;
@property (nonatomic, retain) NSNumber * tradetype;
//For tradetype
//0 for Market Buy
//1 for Limit Buy
//2 for Stop Buy
//3 for Market Sell
//4 for Limit Sell
//5 for Stop Sell

@property (nonatomic, retain) CorePortfolio *portfolio;

@end
