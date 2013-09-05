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

@class Corestock;

@interface Coreportfolio : NSManagedObject

@property (nonatomic, retain) NSNumber * cashvalue;
@property (nonatomic, retain) NSString * portfolio_id;
@property (nonatomic, retain) NSNumber * totalvalue;
@property (nonatomic, retain) NSSet *stocks;
@end

@interface Coreportfolio (CoreDataGeneratedAccessors)

- (void)addStocksObject:(Corestock *)value;
- (void)removeStocksObject:(Corestock *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
