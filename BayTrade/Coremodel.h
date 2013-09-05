//
//  Coremodel.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coreportfolio, Coretradeevent;

@interface Coremodel : NSManagedObject

@property (nonatomic, retain) NSString * model_id;
@property (nonatomic, retain) Coreportfolio *portfolio;
@property (nonatomic, retain) NSSet *tradeevents;
@end

@interface Coremodel (CoreDataGeneratedAccessors)

- (void)addTradeeventsObject:(Coretradeevent *)value;
- (void)removeTradeeventsObject:(Coretradeevent *)value;
- (void)addTradeevents:(NSSet *)values;
- (void)removeTradeevents:(NSSet *)values;


@end
