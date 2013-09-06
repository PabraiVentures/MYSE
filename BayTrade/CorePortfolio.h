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
#import "Stock.h"

@class CoreStock;

//#ifndef Stocks_Portfolio_h
//#define Stocks_Portfolio_h
//
//@interface Portfolio : NSObject
//@property (nonatomic, retain) NSMutableArray *stockList;
//@property (nonatomic) double value;
//
//
//
////add methods for initWithStock and such
//
//+(id) initSelf;
//-(id) initWithStock:(Stock *) theStock;
//-(bool) addStock: (Stock *) addedStock;
//-(Stock *) findStock: (NSString *) symbol;
//-(void) calculateValue;
//@end
//
//
//#endif

@interface CorePortfolio : NSManagedObject

@property (nonatomic, retain) NSString *owner;

@property (nonatomic) double totalcashvalue;
@property (nonatomic, retain) NSString * portfolio_id;
@property (nonatomic, retain) NSMutableArray *stocks;

@end

@interface CorePortfolio (CoreDataGeneratedAccessors)

-(double)totalPortfolioValue;
-(double)totalStockValue;
-(double)totalCashValue;


- (void)addStocksObject:(CoreStock *)value;
- (void)removeStocksObject:(CoreStock *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

+ (CorePortfolio*)initSelf;

@end