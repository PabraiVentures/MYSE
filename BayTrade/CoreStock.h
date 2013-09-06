//
//  Corestock.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreStock : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSNumber * buyprice;
@property (nonatomic, retain) NSNumber * closeprice;
@property (nonatomic, retain) NSNumber * currentprice;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * openprice;
@property (nonatomic, retain) NSNumber * sellprice;
@property (nonatomic, retain) NSString * stock_id;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSNumber * totalvalue;

+(CoreStock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) thePrice AndAmount: (int) theAmount;

@end