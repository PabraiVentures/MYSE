//
//  Coreportfolio.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//
//THIS FILE WAS NOT MADE BY A HUMAN
//COMPLETELY AUTO-GENERATED

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreStock;

@interface CorePortfolio : NSManagedObject

@property (nonatomic, retain) NSString *owner;
@property (nonatomic,retain) NSNumber *totalcashvalue;
@property (nonatomic,retain) NSNumber *totalportfoliovalue;
@property (nonatomic, retain) NSString *coreportfolio_id;
@property (nonatomic, retain) NSMutableSet *stocks;
@property (nonatomic,retain) NSString* portfoliohistory;
@property (nonatomic,retain) NSNumber* ranking;
@property (nonatomic,retain) NSMutableSet *logs;

-(double)totalPortfolioValue;

@end

@interface CorePortfolio (CoreDataGeneratedAccessors)

- (void)addStocksObject:(CoreStock *)value;
- (void)removeStocksObject:(CoreStock *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

+ (CorePortfolio*)initSelf;

@end